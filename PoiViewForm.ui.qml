import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    id: item1
    width: 400
    height: 400

    property alias backButton: backButton
    property alias poiTitle: poiTitle
    property alias navArea: navArea
    property alias distLabel: distLabel
    property alias textDist: textDist
    property alias textBearing: textBearing
    property alias textHeading: textHeading

    ColumnLayout {
        id: columnLayout1
        anchors.fill: parent

Flickable {
    id: flickable1
            clip: true
            flickableDirection: Flickable.VerticalFlick
            anchors.fill: parent

            TextArea {
                id: poiTitle
                height: 80
                text: "Poi Name"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.leftMargin: 0
                font.pointSize: 24
                readOnly: true
                anchors.left: backButton.right
            }

            Rectangle {
                id: navArea
                y: 49
                height: 40
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

            ToolButton {
                id: backButton
                width: 80
                height: 80
                text: "Back"
                activeFocusOnPress: false
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
            }

            TextEdit {
                id: textDist
                width: 80
                height: 20
                text: qsTr("Text Edit")
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: navArea.bottom
                anchors.topMargin: 5
                font.pixelSize: 12
            }

            TextEdit {
                id: textBearing
                width: 80
                height: 20
                text: qsTr("Text Edit")
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: textDist.bottom
                anchors.topMargin: 5
                font.pixelSize: 12
            }

            TextEdit {
                id: textHeading
                width: 80
                height: 20
                text: qsTr("Text Edit")
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: textBearing.bottom
                anchors.topMargin: 5
                font.pixelSize: 12
            }
        }

    }
}

