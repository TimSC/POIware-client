import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import CustomGeometry 1.0

Item {
    anchors.fill: parent

    property real lat: lat
    property real lon: lon
    property var currentPoiid: null
    property var poiToView: null

    property alias downloadAllButton: downloadAllButton
    property alias clearAllButton: clearAllButton
    property alias updatePositionButton: updatePositionButton

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
        height: 50
        width: 100

        anchors.top: latText.bottom
        anchors.topMargin: 5
        anchors.leftMargin: 5
        anchors.left: parent.left
    }

    Button {
        id: clearAllButton
        text: qsTr("Clear All")
        scale: 1
        height: 50
        width: 100

        anchors.top: latText.bottom
        anchors.topMargin: 5
        anchors.leftMargin: 5
        anchors.left: downloadAllButton.right
    }

    Button {
        id: updatePositionButton
        text: qsTr("Update\nPosition")
        scale: 1
        height: 50
        width: 100

        anchors.top: latText.bottom
        anchors.topMargin: 5
        anchors.leftMargin: 5
        anchors.left: clearAllButton.right
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
            if(genEvents && item != null)
                parent.currentPoiid = item.poiid
        }
    }


    Item {
        width: 300
        height: 200

        BezierCurve {
            id: line
            anchors.fill: parent
            anchors.margins: 20
            property real t
            SequentialAnimation on t {
                NumberAnimation { to: 1; duration: 2000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0; duration: 2000; easing.type: Easing.InOutQuad }
                loops: Animation.Infinite
            }

            p2: Qt.point(t, 1 - t)
            p3: Qt.point(1 - t, t)
        }
        Text {
            anchors.bottom: line.bottom

            x: 20
            width: parent.width - 40
            wrapMode: Text.WordWrap

            text: "This curve is a custom scene graph item, implemented using GL_LINE_STRIP"
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

        //console.log("PoiList setCurrentPoiid"+poiid)
    }

    onLatChanged:{
        latText.text = lat
    }

    onLonChanged:{
        lonText.text = lon
    }

}

