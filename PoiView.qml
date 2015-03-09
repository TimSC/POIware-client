import QtQuick 2.4
import QtQuick.LocalStorage 2.0

PoiViewForm {
    property int poiid
    property real dstlat
    property real dstlon
    property real currentLat
    property real currentLon

    focus: true

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
                    parent.processReceivedPoiResult(actualXml)
                }
                else
                    parent.processReceivedPoiResult(null)
            }
            else
            {
                console.log("HTTP status:"+http.status+ " "+http.statusText)
            }
        }

        function go()
        {
            var http = new XMLHttpRequest()
            var url = "http://gis.kinatomic.com/POIware/api"
            var params = "poiid="+parent.poiid+"&action=get"
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

    function processReceivedPoiResult(resultXml)
    {
        var poi = {}

        if(resultXml!= null)
        {
            //Parse POI details
            for (var i = 0; i < resultXml.attributes.length; ++i) {
                if(resultXml.attributes[i].name=="poiid") poi["poiid"] = parseInt(resultXml.attributes[i].value)
                if(resultXml.attributes[i].name=="version") poi["version"] = parseInt(resultXml.attributes[i].value)
            }

            for (var ii = 0; ii < resultXml.childNodes.length; ++ii) {
                var node = resultXml.childNodes[ii]
                if(node.nodeType != 1) continue

                var nodeText = getTextFromNode(node)

                if(node.nodeName == "name")
                    poi["name"] = nodeText
                if(node.nodeName == "lat")
                    poi["lat"] = parseFloat(nodeText)
                if(node.nodeName == "lon")
                    poi["lon"] = parseFloat(nodeText)
                /*if(node.nodeName == "data")
                    dstlon = parseFloat(nodeText)
                if(node.nodeName == "dataset")
                    dstlon = parseFloat(nodeText)*/

            }

            poiTitle.text = poi["name"]
            dstlat = poi["lat"]
            dstlon = poi["lon"]

            poiDatabase.cachePois([poi])
        }
        else
        {
            //Try cached POI
            var poiDetail = poiDatabase.getPoi(poiid)
            poiTitle.text = poiDetail["name"]
            dstlat = poiDetail["lat"]
            dstlon = poiDetail["lon"]
        }

        refreshCalc()

    }

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

    Component.onCompleted: {
        currentLat = 52.
        currentLon = -1.15
    }

    onPoiidChanged:
    {
        console.log("view poi: " + poiid)

        httpQuery.go()


        /*var db = LocalStorage.openDatabaseSync("QQmlExampleDB", "1.0", "The Example QML SQL!", 1000000)

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('SELECT * FROM pois WHERE rowid = ?;', [poiid]);

                for(var i = 0; i < rs.rows.length; i++) {
                    var item = rs.rows.item(i)

                    poiTitle.text = item.name
                    dstlat = item.lat
                    dstlon = item.lon
                }
            }
        )*/


    }

    function setHeading(bearing) {
        textHeading.text = bearing
        //console.log("Bearing changed: " + bearing);
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
        if(pos.latitudeValid)
            currentLat = pos.coordinate.latitude

        if(pos.longitudeValid)
            currentLon = pos.coordinate.longitude

        refreshCalc()
    }

    function refreshCalc()
    {
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

    function getCurrentPoiid()
    {


    }
}

