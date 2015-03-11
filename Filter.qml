import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

FilterForm {
    ListModel
    {
        id: datasetModel

        ListElement {
            name: "Listed buildings"
            datasetId : 1
            chk: 1
        }
        ListElement {
            name: "Scheduled monuments"
            datasetId : 2
            chk: 0
        }
    }

    datasetListView.model: datasetModel

    datasetListView.delegate: Item {
        x: 5
        width: 80
        height: 20
        Row {
            id: row1
            spacing: 10
            CheckBox {
                checked: chk
            }

            Text {
                text: name
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
            }
        }
    }

}

