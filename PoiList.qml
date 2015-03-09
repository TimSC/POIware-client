import QtQuick 2.0

Item {
    anchors.fill: parent

    ListModel
    {
        id: nearbyModel
    }

    ListView {
        id: nearbyList
        anchors.fill: parent

        model: nearbyModel
        clip: true
        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        highlightFollowsCurrentItem: true

        delegate: Item
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
    }

    function clear(){
        nearbyModel.clear()
    }

    function append(item){
        nearbyModel.append(item)
    }

    function getCurrentPoiid(){
        var item = nearbyModel.get(poiList.currentIndex)
        return item.poiid
    }

}

