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

    function parse(resultXml)
    {
        var pois = []
        for (var n = 0; n < resultXml.childNodes.length; ++n)
        {
            var poiNode = resultXml.childNodes[n]
            if(poiNode.nodeType != 1) continue
            if(poiNode.nodeName != "poi") continue
            var poi = {}

            //Parse POI details
            for (var i = 0; i < poiNode.attributes.length; ++i) {
                if(poiNode.attributes[i].name=="poiid") poi["poiid"] = parseInt(poiNode.attributes[i].value)
                if(poiNode.attributes[i].name=="version") poi["version"] = parseInt(poiNode.attributes[i].value)
            }

            for (var ii = 0; ii < poiNode.childNodes.length; ++ii) {
                var node = poiNode.childNodes[ii]
                if(node.nodeType != 1) continue

                var nodeText = getTextFromNode(node)

                if(node.nodeName == "name")
                    poi["name"] = nodeText
                if(node.nodeName == "lat")
                    poi["lat"] = parseFloat(nodeText)
                if(node.nodeName == "lon")
                    poi["lon"] = parseFloat(nodeText)
                /*if(node.nodeName == "data")
                    dstlon = parseFloat(nodeText)
                if(node.nodeName == "dataset")
                    dstlon = parseFloat(nodeText)*/

            }

            pois.push(poi)
        }

        return pois
    }
}
