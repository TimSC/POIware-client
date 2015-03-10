import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    anchors.fill: parent

    property real lat: lat
    property real lon: lon
    property var currentPoiid: null
    property var poiToView: null

    property alias downloadAllButton: downloadAllButton

    ListModel
    {
        id: nearbyModel
    }

    TextField {
        id: latText
        height: 25
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

    TextField {
        id: lonText
        height: 25
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

    Button {
        id: downloadAllButton
        text: qsTr("Download All")
        scale: 1
        height: 25
        width: 100

        anchors.top: latText.bottom
        anchors.topMargin: 5
        anchors.leftMargin: 5
        anchors.left: parent.left
    }

    ListView {
        id: nearbyList
        anchors.top: downloadAllButton.bottom
        anchors.topMargin: 5

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
        property int genEvents: 1

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
                    //Changes the list to show selected item
                    container.ListView.view.currentIndex = index
                }

                onDoubleClicked: {
                    //Changes the list to show selected item
                    container.ListView.view.currentIndex = index
                    var item = nearbyModel.get(index)
                    nearbyList.parent.poiToView = item.poiid
                }
            }
        }

        onCurrentIndexChanged: {
            var item = nearbyModel.get(nearbyList.currentIndex)
            if(genEvents)
                parent.currentPoiid = item.poiid
        }
    }

    function clear(){
        nearbyModel.clear()
    }

    function append(item){
        nearbyModel.append(item)
    }

    function setCurrentPoiid(poiid) {
        var index = null
        for(var i=0;i < nearbyModel.count; i++)
        {
            var item = nearbyModel.get(i)
            if(item.poiid == poiid)
            {
                index = i
                break
            }
        }
        if(index != null)
        {
            nearbyList.genEvents = 0
            nearbyList.currentIndex = index
            nearbyList.genEvents = 1
        }

        console.log("PoiList setCurrentPoiid"+poiid)
    }

    onLatChanged:{
        latText.text = lat
    }

    onLonChanged:{
        lonText.text = lon
    }

}

