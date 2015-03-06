import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.XmlListModel 2.0
import QtPositioning 5.2
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    title: qsTr("Hello World")
    width: 640
    height: 480
    visible: true

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open")
                onTriggered: messageDialog.show(qsTr("Open action triggered"));
            }
            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }
    }

    MagCompass
    {
        id: compass
        onMagChange: {
            poiView.setHeading(bearing)
        }
    }

    PositionSource {
        id: positionSource
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods

        onPositionChanged: {
            var pos = positionSource.position
            console.log("Position changed: " + pos.coordinate)
            poiView.updatePosition(pos)
        }
    }

    XmlListModel
    {
        id: gpxSource
        source: "http://gis.kinatomic.com/POIware/api"
        query: "/gpx/wpt"
        namespaceDeclarations: "declare namespace xsd='http://www.w3.org/2001/XMLSchema'; declare namespace xsi='http://www.w3.org/2001/XMLSchema-instance'; declare default element namespace 'http://www.topografix.com/GPX/1/0';"

        property real currentLat: 52.
        property real currentLon: -1.15

        function updateSource(){
            source = "http://gis.kinatomic.com/POIware/api?lat="+currentLat+"&lon="+currentLon
        }

        onCurrentLatChanged: {
            updateSource()
        }
        onCurrentLonChanged: {
            updateSource()
        }

        XmlRole { name: "lon"; query: "@lon/number()"}
        XmlRole { name: "lat"; query: "@lat/number()"}
        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "urlname"; query: "urlname/string()" }
        XmlRole { name: "url"; query: "url/string()"}
        XmlRole { name: "ele"; query: "ele/number()" }
        XmlRole { name: "version"; query: "extensions/poiware/version/number()" }
        XmlRole { name: "poiid"; query: "extensions/poiware/poiid/number()" }
    }

    ListModel
    {
        id: nearbyModel
    }

    MainForm {
        id: nearbyForm
        anchors.fill: parent
        nearbyList.model: nearbyModel
        nearbyList.clip: true
        nearbyList.highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        nearbyList.highlightFollowsCurrentItem: true

        property int queryInProgress: 1
        property real currentLat: 52.
        property real currentLon: -1.15

        Timer {
            //Timer to check when xml data is ready
            interval: 200
            running: true
            repeat: true
            onTriggered: {

                if(parent.queryInProgress && gpxSource.status == XmlListModel.Ready)
                {
                    console.log("query result ready")
                    parent.processReceivedQueryResult()
                    parent.queryInProgress = 0
                }

                if(parent.queryInProgress && gpxSource.status == XmlListModel.Error)
                {
                    console.log("query result error")
                    console.log("error: " + gpxSource.errorString())
                    parent.queryInProgress = 0
                }
            }
        }

        function viewPoi(poiid) {
            poiView.poiid = poiid
            poiView.visible = true
            nearbyForm.visible = false
        }

        nearbyList.delegate: Item
        {
            id: container
            width: nearbyForm.width; height: 40

            Row {
                id: row1
                Rectangle {
                    width: 40
                    height: 40
                    color: colorCode
                }

                Text {
                    text: name + ": " + dist
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.fill
                }
                spacing: 10
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    //console.log("test1");
                    container.ListView.view.currentIndex = index
                }

                onDoubleClicked: {
                    container.ListView.view.currentIndex = index
                    var item = nearbyModel.get(index)
                    nearbyForm.viewPoi(item.poiid)
                }
            }
        }

        function toRadians(deg) {
            return deg * Math.PI / 180.
        }

        function toDegrees(rad) {
            return rad * 180. / Math.PI
        }

        viewButton.onClicked:
        {
            var item = nearbyModel.get(nearbyList.currentIndex)
            viewPoi(item.poiid)
        }

        function queryDb(){
        var db = LocalStorage.openDatabaseSync("poidb", "1.0", "POI storage", 1000000)

        db.transaction(
            function(tx) {
                //tx.executeSql('DROP TABLE pois;')

                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS pois(rowid INTEGER PRIMARY KEY, name TEXT, lat REAL, lon REAL, version INTEGER)')

                tx.executeSql('DELETE FROM pois;')

                //console.log("test: " + gpxSource.count)
                //console.log("status: " + (gpxSource.status == XmlListModel.Error))
                //console.log("error: " + gpxSource.errorString())
                for(var i=0;i< gpxSource.count; i++)
                {
                    var item = gpxSource.get(i)
                    tx.executeSql('INSERT INTO pois (name, lat, lon) VALUES(?, ?, ?);', [ item.name, item.lat, item.lon ])
                }
            }
        )
        }

        syncButton.onClicked:
        {

        }

        function populateList()
        {
            if(positionSource.position.latitudeValid)
                currentLat = positionSource.position.coordinate.latitude

            if(positionSource.position.longitudeValid)
                currentLon = positionSource.position.coordinate.longitude

            gpxSource.currentLat = currentLat
            gpxSource.currentLon = currentLon
            gpxSource.reload()

            queryInProgress = 1
            console.log("start query")

            //Calculate distance to each poi
            /*var db = LocalStorage.openDatabaseSync("poidb", "1.0", "POI storage", 1000000)


            db.transaction(
                function(tx) {
                var rs = tx.executeSql('SELECT * FROM pois;');

                console.log("current: " + currentLat + "," + currentLon)

                for(var i = 0; i < rs.rows.length; i++) {
                    var item = rs.rows.item(i)

                    //Based on http://www.movable-type.co.uk/scripts/latlong.html
                    var φ1 = toRadians(item.lat), φ2 = toRadians(currentLat), Δλ = toRadians(currentLon-item.lon), R = 6371000.; // gives d in metres
                    var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;

                    poiList.push({"name":item.name, "colorCode": "green", "dist": d, "rowid": item.rowid})
                }
            }
            )*/
        }

        function processReceivedQueryResult()
        {
            var poiList = []

            if(gpxSource.status == XmlListModel.Ready)
            {
                for(var i = 0; i < gpxSource.count; i++) {
                    var item = gpxSource.get(i)

                    //console.log("poiid: " + item.poiid)

                    //Based on http://www.movable-type.co.uk/scripts/latlong.html
                    var φ1 = toRadians(item.lat), φ2 = toRadians(currentLat), Δλ = toRadians(currentLon-item.lon), R = 6371000.; // gives d in metres
                    var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;

                    poiList.push({"name":item.name, "colorCode": "green", "dist": d, "poiid": item.poiid})
                }
            }

            //Sort pois by distance
            poiList.sort(function(a, b){return a["dist"]-b["dist"]})

            //Update the UI model
            nearbyModel.clear()
            for(var i=0;i< poiList.length; i++)
            {
                var item = poiList[i]
                //console.log("item" + item)
                nearbyModel.append({"name":item["name"], "colorCode": item["colorCode"], "dist": item["dist"], "poiid": item.poiid})
            }

        }

        refreshButton.onClicked:
        {
            populateList()
        }

    }

    MessageDialog {
        id: messageDialog
        title: qsTr("May I have your attention, please?")

        function show(caption) {
            messageDialog.text = caption;
            messageDialog.open();
        }
    }

    PoiView {
        id: poiView
        visible: false
        anchors.fill: parent
    }
}
