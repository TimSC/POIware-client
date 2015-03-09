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
    property int maxZoom: 18
    property int minZoom: 0

    property var tiles: ({})
    property var prevTouch: ({})
    property var markers: ({})
    property real gestureThreshold: 5
    property var inGesture: ({})
    property var selectedMarker: null

    MultiPointTouchArea {
        anchors.fill: parent
        mouseEnabled: true

        onPressed:{
            //console.log("pressed " + touchPoints.length)

            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                //console.log(tp.pointId)
                prevTouch[tp.pointId] = [tp.x, tp.y]
                inGesture[tp.pointId] = 0
            }
        }

        onReleased:{
            //console.log("released " + touchPoints.length)

            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]

                if(!inGesture[tp.pointId])
                {
                    parent.handleClick(tp.x, tp.y)
                }

                prevTouch[tp.pointId] = null
                inGesture[tp.pointId] = 0
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
                var mag = Math.pow(dx*dx + dy*dy, 0.5)
                if(mag > gestureThreshold)
                    inGesture = 1

                //console.log("move " + tp.x + "," + tp.y + ";" + dx + "," + dy)
                if(inGesture)
                {
                    translateMap(dx, dy)
                    prevTouch[tp.pointId] = [tp.x, tp.y]
                }
            }
        }

    }

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        property var prevPos: null
        property real gestureThreshold: 5
        property int inGesture: 0

        onPositionChanged: {
            //console.log("move " + mouse.x+","+mouse.y)
            if(prevPos != null)
            {
                var dx = mouse.x - prevPos[0]
                var dy = mouse.y - prevPos[1]
                var mag = Math.pow(dx*dx + dy*dy, 0.5)
                if(mag > gestureThreshold)
                    inGesture = 1

                if(inGesture)
                   translateMap(dx, dy)
            }
            if(inGesture)
                prevPos = [mouse.x, mouse.y]
        }

        onPressed: {
            //console.log("pressed " + mouse.button)
            prevPos = [mouse.x, mouse.y]
            inGesture = 0
        }

        onReleased: {
            //console.log("released " + mouse.button)
            prevPos = null
            if(!inGesture)
            {
                //console.log("click " + mouse.button)
                parent.handleClick(mouse.x, mouse.y)
            }

            inGesture = 0
        }

        onWheel: {
            console.log("wheel " + wheel.buttons + "," + wheel.angleDelta)
            if(wheel.angleDelta.y > 0)
            {
                if(parent.zoom < maxZoom)
                    parent.zoom += 1
            }
            else
            {
                if(parent.zoom > minZoom)
                    parent.zoom -= 1
            }

            checkTilesLoaded()
            repositionTiles()
            repositionMarkers()
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
        repositionMarkers()
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
                    tile.visible = (z == zoom)
                }
            }
        }
    }

    function repositionMarkers(){
        var w = width / tileSize
        var h = height / tileSize
        //console.log("Tile size: "+ w +","+ h)

        var viewx = long2tile(lon, zoom)
        var viewy = lat2tile(lat, zoom)

        //Find top left corner position
        var cornerx = viewx - w * 0.5
        var cornery = viewy - h * 0.5

        for(var markerId in markers)
        {
            var marker = markers[markerId]
            var mx = long2tile(marker.lon, zoom)
            var my = lat2tile(marker.lat, zoom)

            var mdx = mx - cornerx
            var mdy = my - cornery

            marker.setPos(mdx * tileSize, mdy * tileSize)
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
                    var tile = component.createObject(mapArea, {"tx": i, "ty": j, "tzoom": zoom})
                    tiles[zoom][i][j] = tile
                }
            }
        }

        //Unload unnecessary tiles at other zoom levels
        for(var z in tiles)
        {
            if(z == zoom) continue

            for(var x in tiles[z])
            {
                var xrow = tiles[z][x]
                for(var y in xrow)
                {
                    var tile2 = xrow[y]

                    //console.log("Unload: " + tile2.tzoom +","+ tile2.tx + "," + tile2.ty)
                    if(tile2 != null)
                        tile2.destroy()
                    delete xrow[y]
                }
            }

            delete tiles[z]
        }

        //Unload unneeded tiles rows
        for(var x in tiles[zoom])
        {
            var dest = 0
            if(x < cornerx || x > corner2x)
                dest = 1
            if(!dest) continue

            //Delete all tiles in this row
            var xrow = tiles[zoom][x]
            for(var y in xrow)
            {
                //console.log(x+","+y)
                var tile2 = xrow[y]

                //console.log("Unload: " + tile2.tzoom +","+ tile2.tx + "," + tile2.ty)
                if(tile2 != null)
                    tile2.destroy()
                delete xrow[y]
            }

            delete tiles[zoom][x]
        }

        //Unload individual unneeded tiles
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
                    //console.log("Unload: " + tile2.tzoom +","+ tile2.tx + "," + tile2.ty)
                    if(tile2 != null)
                        tile2.destroy()
                    delete xrow[y]
                }
            }

        }

    }

    function addMarker(markerId, lat, lon) {

        //console.log(lat+","+lon)
        if(markerId in markers)
            removeMarker(markerId)

        var component = Qt.createComponent("SlippyMarker.qml");
        //Based on http://qt-project.org/doc/qt-4.8/qdeclarativedynamicobjects.html
        var mark = component.createObject(mapArea, {"lat": lat, "lon": lon})
        markers[markerId] = mark

        repositionMarkers()
    }

    function removeMarker(markerId) {
        var marker = markers[markerId]
        marker.destroy()
        delete markers[markerId]

        if(markerId == selectedMarker)
            selectedMarker = null

        repositionMarkers()
    }

    function removeAllMarkers() {
        for(var markerId in markers)
        {
            var marker = markers[markerId]
            marker.destroy()
        }
        markers = {}
        selectedMarker = null

        repositionMarkers()
    }

    function handleClick(x, y){
        //console.log("click: "+x+","+y)

        var bestMag = null
        var bestMarkerId = null
        var bestMarker = null
        for(var markerId in markers)
        {
            var marker = markers[markerId]
            //console.log(marker.x+","+marker.y)
            var mag = Math.pow(Math.pow(marker.x - x,2.) + Math.pow(marker.y - y,2.), 0.5)
            if(bestMag == null || mag < bestMag)
            {
                bestMag = mag
                bestMarkerId = markerId
                bestMarker = marker
            }
        }

        selectedMarker = bestMarkerId
        setSelectedMarkerFormat(bestMarkerId)
    }

    onWidthChanged: {
        checkTilesLoaded()
        repositionTiles()
        repositionMarkers()
    }

    onHeightChanged:
    {
        checkTilesLoaded()
        repositionTiles()
        repositionMarkers()
    }

    onLatChanged: {
        checkTilesLoaded()
        repositionTiles()
        repositionMarkers()
    }

    onLonChanged: {
        checkTilesLoaded()
        repositionTiles()
        repositionMarkers()
    }

    function setSelectedMarkerFormat(newMarkerId) {

        for(var markerId in markers)
        {
            //Update previous selection
            var marker = markers[markerId]
            marker.selected = 0
        }

        if(newMarkerId != null)
        {
            var marker = markers[newMarkerId]
            marker.selected = 1
        }
    }

    function setSelectedMarker(newMarkerId){
        setSelectedMarkerFormat(newMarkerId)
    }

    function centreOnMarker(markerId){
        if(markerId == null) return
        var marker = markers[markerId]
        lat = marker.lat
        lon = marker.lon
    }

    Component.onCompleted:
    {



    }

}

