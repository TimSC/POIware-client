import QtQuick 2.0

Item {
    property var xmlResponse
    property var textResponse

    function receivedResult(http) { // Call a function when the state changes.
        if (http.status == 200 || http.status == 0)
        {
            textResponse = http.responseText
            if(http.responseXML != null)
            {
                var actualXml = http.responseXML.documentElement;
                xmlResponse = actualXml
            }
            else
                xmlResponse = null
        }
        else
        {
            //console.log("HTTP status:"+http.status+ " "+http.statusText)
        }
    }

    function go(poiids)
    {
        var http = new XMLHttpRequest()
        var url = "http://gis.kinatomic.com/POIware/api"
        var params = "poiid="+poiids.join()+"&action=get"
        var method = "POST"
        http.open(method, url, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);
        http.setRequestHeader("Connection", "close");

        http.onreadystatechange = function() { // Call a function when the state changes.
            if (http.readyState == XMLHttpRequest.DONE) {
                receivedResult(http)
            }
            else
                console.log("HTTP request status: "+http.readyState)
        }
        if(method == "POST")
            http.send(params)
        else
            http.send()

    }
}
