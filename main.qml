import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.XmlListModel 2.0
import QtPositioning 5.2

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

    PositionSource {
        id: positionSource
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods

        onPositionChanged: {
            var pos = positionSource.position
            console.log("Position changed: " + pos.coordinate);
            poiView.updatePosition(pos)
        }
    }

    XmlListModel
    {
        id: gpxSource
        source: "test.gpx"
        query: "/gpx/wpt"
        namespaceDeclarations: "declare namespace xsd='http://www.w3.org/2001/XMLSchema'; declare namespace xsi='http://www.w3.org/2001/XMLSchema-instance'; declare default element namespace 'http://www.topografix.com/GPX/1/0';"

        XmlRole { name: "lon"; query: "@lon/number()"}
        XmlRole { name: "lat"; query: "@lat/number()"}
        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "urlname"; query: "urlname/string()" }
        XmlRole { name: "url"; query: "url/string()"}
        XmlRole { name: "ele"; query: "ele/number()" }
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

        function viewPoi() {
            var index = nearbyList.currentIndex
            console.log("view poi:" + index);

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
                    nearbyForm.viewPoi()
                }
            }
        }

        function toRadians(deg) {
            return deg * Math.PI / 180.;
        }

        function toDegrees(rad) {
            return rad * 180. / Math.PI;
        }

        viewButton.onClicked:
        {
            viewPoi()
        }

        refreshButton.onClicked:
        {
            var currentLat = 51.2365
            var currentLon = -0.5703
            var pos = positionSource.position.coordinate

            if(positionSource.position.latitudeValid)
                currentLat = positionSource.position.coordinate.latitude

            if(positionSource.position.longitudeValid)
                currentLon = positionSource.position.coordinate.longitude

            //Calculate distance to each poi
            var poiList = []
            for(var i=0;i< gpxSource.count; i++)
            {
                var item = gpxSource.get(i)

                //Based on http://www.movable-type.co.uk/scripts/latlong.html
                var φ1 = toRadians(item.lat), φ2 = toRadians(currentLat), Δλ = toRadians(currentLon-item.lon), R = 6371000.; // gives d in metres
                var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;

                poiList.push({"name":item.name, "colorCode": "green", "dist": d})
            }

            //Sort pois by distance
            poiList.sort(function(a, b){return a["dist"]-b["dist"]})

            //Update the UI model
            nearbyModel.clear()
            for(var i=0;i< poiList.length; i++)
            {
                var item = poiList[i]
                //console.log("item" + item)
                nearbyModel.append({"name":item["name"], "colorCode": item["colorCode"], "dist": item["dist"]})
            }
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
        focus: true

        backButton.onClicked: {
            poiView.visible = false
            nearbyForm.visible = true
        }

        Keys.onReleased: {
            if (event.key == Qt.Key_Back && visible) {
                event.accepted = true
                poiView.visible = false
                nearbyForm.visible = true
            }
        }

        function toRadians(deg) {
            return deg * Math.PI / 180.;
        }

        function toDegrees(rad) {
            return rad * 180. / Math.PI;
        }

        function relativeBearing(b1, b2)
        {
            b1y = Math.cos(b1);
            b1x = Math.sin(b1);
            b2y = Math.cos(b2);
            b2x = Math.sin(b2);
            crossp = b1y * b2x - b2y * b1x;
            dotp = b1x * b2x + b1y * b2y;
            if(crossp > 0.)
                return Math.acos(dotp);
            return -Math.acos(dotp);
        }

        function updatePosition(pos)
        {
            var currentLat = 52.
            if(pos.latitudeValid)
                currentLat = pos.coordinate.latitude

            var currentLon = -1.15
            if(pos.longitudeValid)
                currentLon = pos.coordinate.longitude

            var dstlat = 51.0
            var dstlon = -1.0

            //Based on http://www.movable-type.co.uk/scripts/latlong.html
            var φ1 = toRadians(dstlat), φ2 = toRadians(currentLat), Δλ = toRadians(currentLon-dstlon), R = 6371000. // gives d in metres
            var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R
            textDist.text = d

            var φ1 = toRadians(currentLat), φ2 = toRadians(dstlat), λ2 = toRadians(dstlon), λ1 = toRadians(currentLon), R = 6371000.
            var y = Math.sin(λ2-λ1) * Math.cos(φ2)
            var x = Math.cos(φ1)*Math.sin(φ2) - Math.sin(φ1)*Math.cos(φ2)*Math.cos(λ2-λ1)
            var dstbrng = toDegrees(Math.atan2(y, x))
            textBearing.text = dstbrng

        }
    }
}
