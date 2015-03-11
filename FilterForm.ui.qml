import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    id: item1
    width: 400
    height: 400

    property alias datasetListView: datasetListView
    property alias doneButton: doneButton

    ListView {
        id: datasetListView
        anchors.bottom: doneButton.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        clip: true
        anchors.bottomMargin: 5
        delegate: Item {
            x: 5
            width: 80
            height: 40
            Row {
                id: row1
                spacing: 10
                Rectangle {
                    width: 40
                    height: 40
                    color: colorCode
                }

                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
            }
        }
        model: ListModel {
            ListElement {
                name: "Grey"
                colorCode: "grey"
            }

            ListElement {
                name: "Red"
                colorCode: "red"
            }

            ListElement {
                name: "Blue"
                colorCode: "blue"
            }

            ListElement {
                name: "Green"
                colorCode: "green"
            }
        }
    }

    Button {
        id: doneButton
        x: 34
        y: 359
        height: 50
        text: "Done"
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }
}

