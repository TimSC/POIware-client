import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {

    property var db: LocalStorage.openDatabaseSync("poidb", "1.0", "POI storage", 1000000)

    function checkSchema()
    {
        db.transaction(
            function(tx) {
                //tx.executeSql('DROP TABLE pois;')
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS pois(poiid INTEGER PRIMARY KEY, name TEXT, lat REAL, lon REAL, version INTEGER, data TEXT, dataset INT)')
            }
        )
    }

    function cachePois(pois){
        //console.log("cache poi: "+poi["poiid"])

        checkSchema()

        db.transaction(
            function(tx) {

                for(var i=0;i<pois.length;i++)
                {
                    var poi = pois[i]
                    //console.log(poi["poiid"]+","+poi["dataset"])

                    tx.executeSql('DELETE FROM pois WHERE poiid = ?;', [poi["poiid"]])
                    tx.executeSql('INSERT INTO pois (poiid, name, lat, lon, version, dataset) VALUES(?, ?, ?, ?, ?, ?);',
                               [poi["poiid"], poi["name"], poi["lat"], poi["lon"], poi["version"], poi["dataset"]])
                }
            }
        )
    }

    function getPoi(poiid)
    {
        //console.log("start query: "+poiid)

        checkSchema()

        var out = null
        db.transaction(
            function(tx) {

            var rs = tx.executeSql('SELECT * FROM pois WHERE poiid = ?;', [poiid]);
            //console.log("len:"+rs.rows.length)

            out = rs.rows.item(0)
        }
        )

        return out
    }

    function queryPois(lat, lon, enabledDatasets)
    {
        var pois = []

        checkSchema()

        db.transaction(
            function(tx) {

            var conds = []
            var params = []

            //console.log(enabledDatasets)
            if(enabledDatasets!=null && enabledDatasets.length > 0)
            {
                var filt = []
                for(var i=0;i < enabledDatasets.length;i++)
                {
                    filt.push("dataset = ?")
                    params.push(enabledDatasets[i])
                }
                conds.push("("+filt.join(" OR ")+")")

            }
            if(enabledDatasets!=null && enabledDatasets.length== 0)
            {
                conds.push("1=0")
            }

            var cond = "1=1"
            if(conds.length > 0)
                cond = conds.join(" AND ")

            var sql = 'SELECT * FROM pois WHERE '+cond
            //console.log(sql)
            //console.log(params)
            var rs = tx.executeSql(sql, params);

            for(var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i)
                pois.push(item)
            }
        }
        )

        return pois
    }

    function clearPois(pois)
    {
        checkSchema()

        db.transaction(
            function(tx) {

                for(var i=0;i<pois.length;i++)
                {
                    var poiid = pois[i]
                    tx.executeSql('DELETE FROM pois WHERE poiid = ?;', [poiid])
                }
            }
        )
    }
}

