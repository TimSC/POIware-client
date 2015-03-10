import QtQuick 2.0

Rectangle {
    width: 256
    height: 256
    color: "#00000000"
    property int tx: 2040
    property int ty: 1366
    property int tzoom: 12
    property string url: "http://map.fosm.org/default/{z}/{x}/{y}.png"
    //property string url: "http://a.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"

    Image {
        width: 256
        height: 256
        asynchronous: true

        source: {
            var tmp = url
            tmp = tmp.replace("{x}", tx)
            tmp = tmp.replace("{y}", ty)
            return tmp.replace("{z}", tzoom)
        }

        onStatusChanged:{
            if(status != Image.Ready) return
            //console.log("image status changed: " + status)
        }

    }

}
