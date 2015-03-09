import QtQuick 2.0

Rectangle {
    width: 300
    height: 400
    focus: true
    clip: true
    id: mapArea
    property real lat: 51.272286
    property real lon: -0.6671822
    property int zoom: 12
    property int tileSize: 256

    property var tiles: []
    property var prevTouch: ({})

    MultiPointTouchArea {
        anchors.fill: parent

        onPressed:{
            //console.log("pressed " + touchPoints.length)

            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                //console.log(tp.pointId)
                prevTouch[tp.pointId] = [tp.x, tp.y]
            }
        }

        onReleased:{
            //console.log("released " + touchPoints.length)

            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                //console.log(tp.pointId)
                prevTouch[tp.pointId] = null
            }
        }

        onUpdated:{
            //console.log("updated " + touchPoints.length)
            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                //console.log(tp.pointId)

                var dx = tp.x - prevTouch[tp.pointId][0]
                var dy = tp.y - prevTouch[tp.pointId][1]

                //console.log("move " + tp.x + "," + tp.y + ";" + dx + "," + dy)
                translateMap(dx, dy)
                prevTouch[tp.pointId] = [tp.x, tp.y]
            }
        }

    }

    function translateMap(dx, dy){

        var viewx = long2tile(lon, zoom)
        var viewy = lat2tile(lat, zoom)

        viewx -= dx / tileSize
        viewy -= dy / tileSize

        lat = tile2lat(viewy, zoom)
        lon = tile2long(viewx, zoom)

        repositionTiles()
    }

    //From http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
    function long2tile(lon,zoom) { return ((lon+180)/360*Math.pow(2,zoom)); }
    function lat2tile(lat,zoom)  { return (1-Math.log(Math.tan(lat*Math.PI/180) + 1/Math.cos(lat*Math.PI/180))/Math.PI)/2 *Math.pow(2,zoom); }

    function tile2long(x,z) {
        return (x/Math.pow(2,z)*360-180);
    }
    function tile2lat(y,z) {
        var n=Math.PI-2*Math.PI*y/Math.pow(2,z);
        return (180/Math.PI*Math.atan(0.5*(Math.exp(n)-Math.exp(-n))));
    }

    function repositionTiles(){

        var w = width / tileSize
        var h = height / tileSize
        console.log("Tile size: "+ w +","+ h)
        var viewx = long2tile(lon, zoom)
        var viewy = lat2tile(lat, zoom)

        console.log("view" + viewx + ","+ viewy)

        //Find top left corner position
        var cornerx = viewx - w * 0.5
        var cornery = viewy - h * 0.5

        //var cornerLat = tile2lat(cornery, zoom)
        //var cornerLon = tile2long(cornerx, zoom)

        for(var i=0; i< tiles.length;i++)
        {
            var tile = tiles[i]
            var tdx = (tile.tx - cornerx)
            var tdy = (tile.ty - cornery)
            console.log("x" + tdx)
            console.log("y" + tdy)
            tile.x = tdx * tileSize
            tile.y = tdy * tileSize
        }
    }



    Component.onCompleted:
    {
        //Based on http://qt-project.org/doc/qt-4.8/qdeclarativedynamicobjects.html
        var component = Qt.createComponent("SlippyTile.qml");
        var tile = component.createObject(mapArea, {"tx": 2040, "ty": 1366})
        tiles.push(tile)
        var tile2 = component.createObject(mapArea, {"tx": 2041, "ty": 1366, "color": "blue"})
        tiles.push(tile2)

        repositionTiles()
    }

}

