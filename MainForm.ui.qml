import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    id: item1
    width: 640
    height: 480

    property alias viewListButton: viewListButton
    property alias viewButton: viewButton
    property alias viewMapButton: viewMapButton
    property alias centralArea: centralArea
    property alias searchButton: searchButton
    property alias titleText: titleText
    property alias descriptionText: descriptionText

    ColumnLayout {
        id: columnLayout1
        anchors.fill: parent
    }

    RowLayout {
        id: bottomRowLayout
        y: 421
        height: 60
        scale: 1
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        Button {
            id: viewButton
            text: qsTr("View")
            anchors.right: parent.right
            anchors.rightMargin: 5
            scale: 1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        TextField {
            id: titleText
            height: 20
            text: qsTr("")
            font.bold: true
            clip: true
            readOnly: true
            anchors.right: viewButton.left
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 0
            font.pixelSize: 12
        }

        TextField {
            id: descriptionText
            height: 20
            text: qsTr("")
            clip: true
            readOnly: true
            anchors.right: viewButton.left
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 30
            font.pixelSize: 12
        }
    }

    RowLayout {
        id: topRowLayout
        height: 60
        scale: 1
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Button {
            id: viewListButton
            text: qsTr("List")
            scale: 1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
        }

        Button {
            id: viewMapButton
            text: qsTr("Map")
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.left: viewListButton.right
            anchors.leftMargin: 5
        }

        Button {
            id: searchButton
            text: qsTr("Search")
            anchors.left: viewMapButton.right
            anchors.leftMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
        }
    }

    Rectangle {
        id: centralArea
        color: "#00000000"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: topRowLayout.bottom
        anchors.topMargin: 5
        anchors.bottom: bottomRowLayout.top
        anchors.bottomMargin: 5
    }
}
