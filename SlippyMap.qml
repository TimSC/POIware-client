import QtQuick 2.0

Rectangle {
    width: 300
    height: 400
    focus: true
    clip: true
    id: mapArea

    property var tiles: []
    property var prevTouch: ({})

    MultiPointTouchArea {
        anchors.fill: parent

        onPressed:{
            console.log("pressed " + touchPoints.length)

            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                console.log(tp.pointId)
                prevTouch[tp.pointId] = [tp.x, tp.y]
            }
        }

        onReleased:{
            console.log("released " + touchPoints.length)

            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                console.log(tp.pointId)
                prevTouch[tp.pointId] = null
            }
        }

        onUpdated:{
            console.log("updated " + touchPoints.length)
            for(var i =0; i <touchPoints.length;i++)
            {
                var tp = touchPoints[i]
                console.log(tp.pointId)

                var dx = tp.x - prevTouch[tp.pointId][0]
                var dy = tp.y - prevTouch[tp.pointId][1]

                //console.log("move " + tp.x + "," + tp.y + ";" + dx + "," + dy)
                translateMap(dx, dy)
                prevTouch[tp.pointId] = [tp.x, tp.y]
            }
        }

    }

    function translateMap(dx, dy){
        for(var i=0; i< tiles.length;i++)
        {
            var tile = tiles[i]
            tile.x += dx
            tile.y += dy
        }
    }

    Component.onCompleted:
    {
        //Based on http://qt-project.org/doc/qt-4.8/qdeclarativedynamicobjects.html
        var component = Qt.createComponent("SlippyTile.qml");
        var tile = component.createObject(mapArea, {"x": 100, "y": 100})
        tiles.push(tile)
        var tile2 = component.createObject(mapArea, {"x": 200, "y": 100, "color": "blue"})
        tiles.push(tile2)
    }

}

