import QtQuick 2.0

Rectangle {
    width: 10
    height: 10
    color: "blue"
    x: 0
    y: 0
    z: 1
    radius: 5

    property real lat
    property real lon
    property int selected

    onSelectedChanged:{
        if(selected)
            color= "yellow"
        else
            color= "blue"
    }

    function setPos(xIn, yIn){
        x = xIn - width/2
        y = yIn - height/2
    }

    function getPos(){
        return [x + width/2, y + height/2]
    }

}
