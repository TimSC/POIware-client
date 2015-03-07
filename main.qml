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
            console.log("Position changed: " + pos.coordinate)
            poiView.updatePosition(pos)
        }
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

        property real currentLat: 52.
        property real currentLon: -1.15

        PoiDatabase {
            id: poiDatabase

        }

        Item {
            id: httpQuery
            function receivedResult(http) { // Call a function when the state changes.
                if (http.status == 200 || http.status == 0)
                {
                    var actualXml = http.responseXML.documentElement;
                    if(actualXml==null)
                    {
                        console.log("responseXml is null")
                    }
                    else
                        parent.processReceivedQueryResult(actualXml)
                }
                else
                {
                    console.log("HTTP status:"+http.status+ " "+http.statusText)
                }
            }

            function showRequestInfo(text) {
                //log.text = log.text + "\n" + text
                //console.log(text)
            }

            function go()
            {
                var http = new XMLHttpRequest()
                var url = "http://gis.kinatomic.com/POIware/api"
                var params = "lat="+parent.currentLat+"&lon="+parent.currentLon+"&action=query"
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
                        console.log("HTTP request status: "+http.readyState)
                }
                if(method == "POST")
                    http.send(params)
                else
                    http.send()

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
        }

        function getTextFromNode(xmlNode)
        {
            var out = ""
            for (var ii = 0; ii < xmlNode.childNodes.length; ++ii) {
                var cn = xmlNode.childNodes[ii]
                if(cn.nodeType != 3) continue
                out += cn.nodeValue
            }
            return out
        }

        function processReceivedQueryResult(resultXml)
        {
            var poiList = []

            //Parse GPX
            for (var ii = 0; ii < resultXml.childNodes.length; ++ii) {
                var node = resultXml.childNodes[ii]
                if(node.nodeType != 1) continue
                if(node.nodeName != "wpt") continue
                var wpt = {}

                for (var iii = 0; iii < node.attributes.length; ++iii) {
                    if(node.attributes[iii].name=="lat") wpt["lat"] = parseFloat(node.attributes[iii].value)
                    if(node.attributes[iii].name=="lon") wpt["lon"] = parseFloat(node.attributes[iii].value)
                }

                for (var iii = 0; iii < node.childNodes.length; ++iii) {
                    var node2 = node.childNodes[iii]
                    if(node2.nodeType != 1) continue
                    //console.log(node2.nodeName)
                    if(node2.nodeName == "name")
                        wpt["name"] = getTextFromNode(node2)

                    if(node2.nodeName == "extensions")
                    {
                        for (var i4 = 0; i4 < node2.childNodes.length; ++i4) {
                            var node3 = node2.childNodes[i4]
                            if(node3.nodeType != 1) continue
                            if(node3.nodeName != "poiware") continue

                            for (var i5 = 0; i5 < node3.childNodes.length; ++i5) {
                                var node4 = node3.childNodes[i5]
                                if(node4.nodeType != 1) continue
                                wpt[node4.nodeName] = getTextFromNode(node4)
                            }
                        }
                    }
                }

                //{"name":item.name, "colorCode": "green", "dist": d, "poiid": item.poiid}
                poiList.push(wpt)

            }

            //Calculate distance to POIs
            var poiDistList = []
            console.log(poiList.length)

            for(var i = 0; i < poiList.length; i++) {
                var item = poiList[i]

                console.log("poiid: " + item.poiid + "," + item.lat + "," + item.lon)

                //Based on http://www.movable-type.co.uk/scripts/latlong.html
                var φ1 = toRadians(item.lat), φ2 = toRadians(currentLat), Δλ = toRadians(currentLon-item.lon), R = 6371000.; // gives d in metres
                var d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;

                poiDistList.push({"name":item.name, "dist": d, "poiid": item.poiid})
            }
            console.log(poiDistList.length)

            //Sort POIs by distance
            poiDistList.sort(function(a, b){return a["dist"]-b["dist"]})

            //Update the UI model
            nearbyModel.clear()
            for(var i=0;i< poiDistList.length; i++)
            {
                var item = poiDistList[i]
                //console.log("item" + item)
                nearbyModel.append({"name":item["name"], "colorCode": "green", "dist": item["dist"], "poiid": item.poiid})
            }

        }

        refreshButton.onClicked:
        {
            httpQuery.go()
            //populateList()
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
