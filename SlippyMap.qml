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
    property int dragActive: 0
    property int tileSize: 256
    property int maxZoom: 18
    property int minZoom: 0

    property real currentLat
    property real currentLon
    property real currentHeading

    property var tiles: ({})
    property var markers: ({})
    property var selectedMarker: null

    MultiPointTouchArea {
        anchors.fill: parent
        mouseEnabled: false
        z: 1
        property real gestureThreshold: 30
        property var prevTouch: ({})
        property var initialTouch: ({})
        property var currentTouch: ({})
        property var inGesture: ({})

        onPressed:{

            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                console.log("pressed " + tp.pointId)
                //console.log(tp.pointId)
                prevTouch[tp.pointId] = [tp.x, tp.y]
                initialTouch[tp.pointId] = [tp.x, tp.y]
                currentTouch[tp.pointId] = [tp.x, tp.y]
                inGesture[tp.pointId] = 0
            }
        }

        onReleased:{


            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                console.log("released " + tp.pointId)

                if(!inGesture[tp.pointId])
                {
                    parent.handleClick(tp.x, tp.y)
                }

                delete prevTouch[tp.pointId]
                delete initialTouch[tp.pointId]
                delete currentTouch[tp.pointId]
                delete inGesture[tp.pointId]
            }


        }

        onUpdated:{

            var keys = Object.keys(initialTouch)
            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                currentTouch[tp.pointId] = [tp.x, tp.y]
            }

            //Calc initial touch average position
            var ilx = []
            var ily = []
            for(var i =0; i <keys.length;i++)
            {
                var it = initialTouch[keys[i]]
                ilx.push(it[0])
                ily.push(it[1])
            }
            var ix = ilx.reduce(function(a, b) { return a + b; }) / ilx.length
            var iy = ily.reduce(function(a, b) { return a + b; }) / ily.length
            console.log("a"+ix+","+iy)

            //Calc current touch average position
            var clx = []
            var cly = []
            for(var i =0; i <keys.length;i++)
            {
                var ct = currentTouch[keys[i]]
                clx.push(ct[0])
                cly.push(ct[1])
            }
            var cx = clx.reduce(function(a, b) { return a + b; }) / clx.length
            var cy = cly.reduce(function(a, b) { return a + b; }) / cly.length
            console.log("b"+cx+","+cy)

            console.log("Av Move: "+(cx - ix)+","+(cy - iy))

            //Calc average initial distance
            var d = []
            for(var i =0; i <keys.length;i++)
            {
                var it = initialTouch[keys[i]]
                d.push(Math.pow(Math.pow(it[0] - ix, 2.) + Math.pow(it[1] - iy, 2.), 0.5))
            }
            var id = d.reduce(function(a, b) { return a + b; }) / d.length

            //Calc current initial distance
            d = []
            for(var i =0; i <keys.length;i++)
            {
                var it = currentTouch[keys[i]]
                d.push(Math.pow(Math.pow(it[0] - cx, 2.) + Math.pow(it[1] - cy, 2.), 0.5))
            }
            var cd = d.reduce(function(a, b) { return a + b; }) / d.length


            console.log("dist:"+ id + ","+ cd)
            var ddist = 1.
            if(initDist > 0.)
                ddist = cd / id
            console.log("ddist:"+ddist)



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
                   dragMove(dx, dy, 0)
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

    SlippyMarker {
        id: currentPosMarker
        color: "green"
        visible: false
    }

    function dragStart(){


    }

    function dragMove(dx, dy, dzoom){

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

    function dragEnd(){

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

        //Update current position
        var marker = currentPosMarker
        var mx = long2tile(currentLon, zoom)
        var my = lat2tile(currentLat, zoom)

        var mdx = mx - cornerx
        var mdy = my - cornery

        marker.setPos(mdx * tileSize, mdy * tileSize)

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
            var markerPos = marker.getPos()
            var mag = Math.pow(Math.pow(markerPos[0] - x,2.) + Math.pow(markerPos[1] - y,2.), 0.5)
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

    function centreOnPosition(latIn, lonIn){
        lat = latIn
        lon = lonIn
    }

    function setCurrentPos(posInfo)
    {
        if(posInfo.latitudeValid)
        {
            currentPosMarker.visible = true
            currentLat = posInfo.coordinate.latitude
        }

        if(posInfo.longitudeValid)
            currentLon = posInfo.coordinate.longitude
    }

    function setCurrentHeading(headingIn){
        currentHeading = headingIn
    }

    Component.onCompleted:
    {



    }

}

