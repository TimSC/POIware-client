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

    ApiMultiPoi{
        id: httpQuery

        onXmlResponseChanged: {
            processReceivedPoiResult(xmlResponse)
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
            for (var n = 0; n < resultXml.childNodes.length; ++n)
            {
                var poiNode = resultXml.childNodes[n]
                if(poiNode.nodeType != 1) continue
                if(poiNode.nodeName != "poi") continue

                //Parse POI details
                for (var i = 0; i < poiNode.attributes.length; ++i) {
                    if(poiNode.attributes[i].name=="poiid") poi["poiid"] = parseInt(poiNode.attributes[i].value)
                    if(poiNode.attributes[i].name=="version") poi["version"] = parseInt(poiNode.attributes[i].value)
                }

                for (var ii = 0; ii < poiNode.childNodes.length; ++ii) {
                    var node = poiNode.childNodes[ii]
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

        httpQuery.go([poiid])
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

