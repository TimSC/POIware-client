import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    anchors.fill: parent

    property real lat: lat
    property real lon: lon

    ListModel
    {
        id: nearbyModel
    }

    TextArea {
        id: latText
        height: 50
        width: 200
        text: "lat"
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.leftMargin: 0
        anchors.left: parent.left

        font.pointSize: 12
        readOnly: false

        onTextChanged:{
            parent.lat = parseFloat(text)
        }
    }

    TextArea {
        id: lonText
        height: 50
        width: 200
        text: "lon"
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.leftMargin: 5
        anchors.left: latText.right

        font.pointSize: 12
        readOnly: false

        onTextChanged:{
            parent.lon = parseFloat(text)
        }
    }

    ListView {
        id: nearbyList
        anchors.top: latText.bottom
        anchors.topMargin: 0

        anchors.leftMargin: 0
        anchors.left: parent.left
        anchors.rightMargin: 0
        anchors.right: parent.right
        anchors.bottomMargin: 0
        anchors.bottom: parent.bottom

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

    onLatChanged:{
        latText.text = lat
    }

    onLonChanged:{
        lonText.text = lon
    }

}

