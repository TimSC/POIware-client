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
            //console.log("Position changed: " + pos.coordinate)
            poiView.updatePosition(pos)
        }
    }

    MainForm {
        id: nearbyForm
        anchors.fill: parent

        property real currentLat: 52.
        property real currentLon: -1.15
        property var currentResultsByDistance: null
        property var currentResultsById: null
        property var selectedPoi: null
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        PoiDatabase {
            id: poiDatabase

        }

        Item {
            id: httpQuery
            function receivedResult(http) { // Call a function when the state changes.

                if (http.status == 200 || http.status == 0)
                {
                    if(http.responseXML != null)
                    {
                        var actualXml = http.responseXML.documentElement;
                        parent.processReceivedQueryResult(actualXml)
                    }
                    else
                        parent.processReceivedQueryResult(null)
                }
                else
                {
                    //console.log("HTTP status:"+http.status+ " "+http.statusText)
                }
            }

            function go(lat, lon)
            {
                var http = new XMLHttpRequest()
                var url = "http://gis.kinatomic.com/POIware/api"
                var params = "lat="+lat+"&lon="+lon+"&action=query"
                var method = "POST"
                http.open(method, url, true);

                // Send the proper header information along with the request
                http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                http.setRequestHeader("Content-length", params.length);
                http.setRequestHeader("Connection", "close");

                http.onreadystatechange = function() { // Call a function when the state changes.
                    if (http.readyState == XMLHttpRequest.DONE) {
                        receivedResult(http)
                    }
                    else
                    {
                        //console.log("HTTP request status: "+http.readyState)
                    }
                }
                if(method == "POST")
                    http.send(params)
                else
                    http.send()

            }
        }

        ApiMultiPoi{
            id: multiPoiQuery

            onXmlResponseChanged: {

                parent.downloadMultiPoisResult(xmlResponse)
            }
        }

        ParsePoiXml{
            id: parsePoiXml

        }

        function downloadMultiPoisResult(xml){
            var pois = parsePoiXml.parse(xml)
            console.log("Parsed num POIs:"+pois.length)

            poiDatabase.cachePois(pois)
            updatePoisFromCurrentResult()
        }

        function viewPoi(poiid) {
            if(poiid === null) return
            poiView.poiid = poiid
            poiView.visible = true
            nearbyForm.visible = false
        }

        function startQuery(lat, lon){
            httpQuery.go(lat, lon)
        }

        viewMapButton.onClicked:
        {
            slippyMap.visible = true
            poiList.visible = false
            viewMapButton.checked = true
            viewListButton.checked = false
        }

        function toRadians(deg) {
            return deg * Math.PI / 180.
        }

        function toDegrees(rad) {
            return rad * 180. / Math.PI
        }

        viewButton.onClicked:
        {
            viewPoi(selectedPoi)
        }

        function updateLowerBarInfo(poiid)
        {
            if(poiid != null)
            {
                var record = currentResultsById[poiid]
                //console.log(record.name)
                titleText.text = record.name
                titleText.cursorPosition = 0
                descriptionText.text = record.name
                descriptionText.cursorPosition = 0
            }
        }

        SlippyMap{
            id: slippyMap
            visible: false
            anchors.fill: parent.centralArea

            Button {
                id: centreMap
                text: qsTr("Centre\nMap")
                width:50
                height:50
                z:10
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.topMargin: 5

                onClicked: {
                    var latVal = parent.lat
                    var lonVal = parent.lon

                    if(positionSource.position.latitudeValid)
                        latVal = positionSource.position.coordinate.latitude

                    if(positionSource.position.longitudeValid)
                        lonVal = positionSource.position.coordinate.longitude

                    parent.centreOnPosition(latVal, lonVal)
                }
            }

            onSelectedMarkerChanged: {
                poiList.setCurrentPoiid(selectedMarker)
                parent.selectedPoi = selectedMarker
                parent.updateLowerBarInfo(selectedMarker)
            }
        }

        PoiList {
            id: poiList
            anchors.fill: parent.centralArea

            onCurrentPoiidChanged: {
                slippyMap.setSelectedMarker(currentPoiid)
                slippyMap.centreOnMarker(currentPoiid)
                parent.selectedPoi = currentPoiid

                parent.updateLowerBarInfo(currentPoiid)
            }

            onPoiToViewChanged:
            {
                //parent.updateLowerBarInfo(poiToView)
                parent.viewPoi(poiToView)
            }

            downloadAllButton.onClicked:
            {
                var keys =[]
                for(var k in parent.currentResultsById)
                    keys.push(k)
                multiPoiQuery.go(keys)

            }

            clearAllButton.onClicked:
            {
                var keys =[]
                for(var k in parent.currentResultsById)
                    keys.push(k)
                poiDatabase.clearPois(keys)
                parent.updatePoisFromCurrentResult()
            }

            updatePositionButton.onClicked: {
                if(positionSource.position.latitudeValid)
                    lat = positionSource.position.coordinate.latitude

                if(positionSource.position.longitudeValid)
                    lon = positionSource.position.coordinate.longitude
            }

        }

        ParseGpx{
            id: parseGpx
        }

        function processReceivedQueryResult(resultXml)
        {
            var poiListTmp = []
            if(resultXml != null)
                poiListTmp = parseGpx.parseGpx(resultXml)

            if(poiListTmp.length == 0)
               poiListTmp = poiDatabase.queryPois()

            //Calculate distance to POIs
            var poiDistList = []
            //console.log(poiListTmp.length)

            for(var i = 0; i < poiListTmp.length; i++) {
                var item = poiListTmp[i]

                //console.log("poiid: " + item.poiid + "," + item.lat + "," + item.lon)

                //Based on http://www.movable-type.co.uk/scripts/latlong.html
                var φ1 = toRadians(item.lat), φ2 = toRadians(currentLat), Δλ = toRadians(currentLon-item.lon), R = 6371000.; // gives d in metres
                var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;

                poiDistList.push({"name":item.name, "dist": d, "poiid": item.poiid, "lat": item.lat, "lon": item.lon})
            }
            //console.log(poiDistList.length)

            //Sort POIs by distance
            poiDistList.sort(function(a, b){return a["dist"]-b["dist"]})

            //Index POIs by id
            currentResultsById = {}
            currentResultsByDistance = poiDistList
            for(var i=0;i< poiDistList.length; i++)
            {
                var item = poiDistList[i]
                currentResultsById[item.poiid] = item
            }

            updatePoisFromCurrentResult()
        }

        function updatePoisFromCurrentResult(){
            //Update the UI models
            poiList.clear()
            slippyMap.removeAllMarkers()
            for(var i =0; i< currentResultsByDistance.length; i++)
            {
                var item = currentResultsByDistance[i]

                //Check if this POI has been cached
                //console.log(item.poiid)
                var poiDetail = poiDatabase.getPoi(item.poiid)

                var colour = "green"
                if(poiDetail != null)
                    colour = "red"

                //console.log("item" + item)
                poiList.append({"name":item["name"], "colorCode": colour, "dist": item["dist"], "poiid": item.poiid})

                slippyMap.addMarker(item.poiid, item.lat, item.lon)
            }
        }

        Component.onCompleted: {
            if(positionSource.position.latitudeValid)
                currentLat = positionSource.position.coordinate.latitude

            if(positionSource.position.longitudeValid)
                currentLon = positionSource.position.coordinate.longitude

            var initLat = 51.
            var initLon = -1.

            startQuery(initLat, initLon)

            slippyMap.lat = initLat
            slippyMap.lon = initLon

            poiList.lat = initLat
            poiList.lon = initLon
        }

        viewListButton.onClicked:
        {
            slippyMap.visible = false
            poiList.visible = true
            viewMapButton.checked = false
            viewListButton.checked = true
        }

        searchButton.onClicked: {

            var queryLat = 51.
            var queryLon = -1.

            if(slippyMap.visible)
            {
                queryLat = slippyMap.lat
                queryLon = slippyMap.lon

                poiList.lat = slippyMap.lat
                poiList.lon = slippyMap.lon
            }

            if(poiList.visible)
            {
                queryLat = poiList.lat
                queryLon = poiList.lon

                slippyMap.lat = poiList.lat
                slippyMap.lon = poiList.lon
            }

            console.log(queryLat+","+queryLon)
            startQuery(queryLat, queryLon)
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
