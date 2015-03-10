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

    ParsePoiXml{
        id: parsePoiXml
    }

    function processReceivedPoiResult(resultXml)
    {
        if(resultXml!= null)
        {
            var pois = parsePoiXml.parse(resultXml)

            if(pois.length > 0)
            {
                poiTitle.text = pois[0]["name"]
                dstlat = pois[0]["lat"]
                dstlon = pois[0]["lon"]
            }

            poiDatabase.cachePois(pois)
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

