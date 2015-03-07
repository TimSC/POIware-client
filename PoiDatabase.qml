import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {

    function cachePoi(poi){
        console.log("TODO cache poi")

        /*var db = LocalStorage.openDatabaseSync("poidb", "1.0", "POI storage", 1000000)

        db.transaction(
            function(tx) {
                //tx.executeSql('DROP TABLE pois;')

                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS pois(rowid INTEGER PRIMARY KEY, name TEXT, lat REAL, lon REAL, version INTEGER)')

                tx.executeSql('DELETE FROM pois;')

                //console.log("test: " + gpxSource.count)
                //console.log("status: " + (gpxSource.status == XmlListModel.Error))
                //console.log("error: " + gpxSource.errorString())
                for(var i=0;i< gpxSource.count; i++)
                {
                    var item = gpxSource.get(i)
                    tx.executeSql('INSERT INTO pois (name, lat, lon) VALUES(?, ?, ?);', [ item.name, item.lat, item.lon ])
                }
            }
        )*/
    }

    function queryPoi(poiid)
    {
        console.log("start query")

        //Calculate distance to each poi
        var db = LocalStorage.openDatabaseSync("poidb", "1.0", "POI storage", 1000000)

        db.transaction(
            function(tx) {
            var rs = tx.executeSql('SELECT * FROM pois;');

            console.log("current: " + currentLat + "," + currentLon)

            for(var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i)

            }
        }
        )
    }
}

