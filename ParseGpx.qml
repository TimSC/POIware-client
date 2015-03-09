import QtQuick 2.0

Item {

    function getTextFromNode(xmlNode)
    {
        var out = ""
        for (var ii = 0; ii < xmlNode.childNodes.length; ++ii) {
            var cn = xmlNode.childNodes[ii]
            if(cn.nodeType != 3) continue
            out += cn.nodeValue
        }
        return out
    }

    function parseGpx(resultXml)
    {
        var poiList = []

        //Parse GPX
        for (var ii = 0; ii < resultXml.childNodes.length; ++ii) {
            var node = resultXml.childNodes[ii]
            if(node.nodeType != 1) continue
            if(node.nodeName != "wpt") continue
            var wpt = {}

            for (var iii = 0; iii < node.attributes.length; ++iii) {
                if(node.attributes[iii].name=="lat") wpt["lat"] = parseFloat(node.attributes[iii].value)
                if(node.attributes[iii].name=="lon") wpt["lon"] = parseFloat(node.attributes[iii].value)
            }

            for (var iii = 0; iii < node.childNodes.length; ++iii) {
                var node2 = node.childNodes[iii]
                if(node2.nodeType != 1) continue
                //console.log(node2.nodeName)
                if(node2.nodeName == "name")
                    wpt["name"] = getTextFromNode(node2)

                if(node2.nodeName == "extensions")
                {
                    for (var i4 = 0; i4 < node2.childNodes.length; ++i4) {
                        var node3 = node2.childNodes[i4]
                        if(node3.nodeType != 1) continue
                        if(node3.nodeName != "poiware") continue

                        for (var i5 = 0; i5 < node3.childNodes.length; ++i5) {
                            var node4 = node3.childNodes[i5]
                            if(node4.nodeType != 1) continue
                            wpt[node4.nodeName] = getTextFromNode(node4)
                        }
                    }
                }
            }

            //{"name":item.name, "colorCode": "green", "dist": d, "poiid": item.poiid}
            poiList.push(wpt)

        }

        return poiList

    }

}

