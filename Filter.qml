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
            chk: true
            chkOut: true
            chkIndex: 0
        }
        ListElement {
            name: "Scheduled monuments"
            datasetId : 2
            chk: true
            chkOut: true
            chkIndex: 1
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

                onClicked: {
                    var item = datasetModel.get(chkIndex)
                    item.chkOut = checked
                    datasetModel.set(chkIndex, item)
                }
            }

            Text {
                text: name
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
            }
        }
    }

    function getFilters()
    {
        var enabled = []
        for(var i=0;i<datasetModel.count; i++)
        {
            var item = datasetModel.get(i)
            if(!item.chkOut) continue
            enabled.push(item.datasetId)

        }
        return enabled
    }
}
