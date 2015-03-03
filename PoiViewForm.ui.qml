import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    id: item1
    width: 400
    height: 400

    property alias button1: button1

    ColumnLayout {
        id: columnLayout1
        anchors.fill: parent

        Flickable {
            id: flickable1
            flickableDirection: Flickable.VerticalFlick
            anchors.fill: parent

            TextArea {
                id: poiTitle
                height: 50
                text: "Poi Name"
                font.pointSize: 24
                readOnly: true
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
            }

            Rectangle {
                id: navArea
                y: 49
                height: 20
                color: "#ffffff"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: poiTitle.bottom
                anchors.topMargin: 0
            }

            Label {
                id: distLabel
                x: 355
                text: qsTr("Label")
                anchors.right: navArea.right
                anchors.rightMargin: 0
                anchors.top: navArea.top
                anchors.topMargin: 0
            }
        }

        Button {
            id: button1
            x: 22
            y: 92
            text: qsTr("Button")
        }
    }
}

