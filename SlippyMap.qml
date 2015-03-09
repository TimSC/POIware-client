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

    property var tiles: ({})
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

        checkTilesLoaded()
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
        //console.log("Tile size: "+ w +","+ h)

        for(var z in tiles)
        {
            var viewx = long2tile(lon, z)
            var viewy = lat2tile(lat, z)

            //Find top left corner position
            var cornerx = viewx - w * 0.5
            var cornery = viewy - h * 0.5

            var xrow = tiles[z]
            for(var x in xrow)
            {
                var yrow = xrow[x]
                for(var y in yrow)
                {
                    var tile = yrow[y]
                    if(tile == null) continue
                    var tdx = (tile.tx - cornerx)
                    var tdy = (tile.ty - cornery)

                    tile.x = tdx * tileSize
                    tile.y = tdy * tileSize
                }
            }
        }
    }

    function checkTilesLoaded() {

        var w = width / tileSize
        var h = height / tileSize
        var viewx = long2tile(lon, zoom)
        var viewy = lat2tile(lat, zoom)

        //Find top left corner position, then round down
        var cornerx = Math.floor(viewx - w * 0.5)
        var cornery = Math.floor(viewy - h * 0.5)

        //Find bottom right corner position, then round down
        var corner2x = Math.floor(viewx + w * 0.5)
        var corner2y = Math.floor(viewy + h * 0.5)

        var component = Qt.createComponent("SlippyTile.qml");

        //Load necessary tiles
        if(!(zoom in tiles)) tiles[zoom] = {}
        for(var i = cornerx; i <= corner2x; i++)
        {
            if(!(i in tiles[zoom])) tiles[zoom][i] = {}
            for(var j = cornery; j <= corner2y; j++)
            {
                if(!(j in tiles[zoom][i]) || tiles[zoom][i][j] == null)
                {
                    //Based on http://qt-project.org/doc/qt-4.8/qdeclarativedynamicobjects.html
                    var tile = component.createObject(mapArea, {"tx": i, "ty": j})
                    tiles[zoom][i][j] = tile
                }
            }
        }

        //Unload unnecessary tiles
        for(var x in tiles[zoom])
        {
            //console.log(x)
            var xrow = tiles[zoom][x]
            for(var y in xrow)
            {
                //console.log(x+","+y)
                var tile2 = xrow[y]
                var dest = 0
                if(x < cornerx || x > corner2x || y < cornery || y > corner2y)
                    dest = 1
                if(dest)
                {
                    //console.log("Unload: " + tile2.tx + "," + tile2.ty + [x, y, cornerx, cornery, corner2x, corner2y])
                    if(tile2 != null)
                        tile2.destroy()
                    xrow[y] = null
                }
            }

        }

        //Clean tile tree structure
        //TODO

    }

    onWidthChanged: {
        checkTilesLoaded()
        repositionTiles()
    }

    onHeightChanged:
    {
        checkTilesLoaded()
        repositionTiles()
    }


    Component.onCompleted:
    {



    }

}

