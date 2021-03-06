import QtQuick 2.0
import QtSensors 5.0

Item {
    id: baseCompass

    property real demoHeading
    property int realCompass
    signal magChange (real bearing)

    Timer {
        //Timer for demo rotation of compass
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            demoHeading += 5.
            if (demoHeading >= 360.)
                demoHeading -= 360.
            if (realCompass != 1)
                baseCompass.magChange(demoHeading)
        }
    }

    Magnetometer {
        id: mag
        dataRate: 5
        active:true

        onReadingChanged: {
            //console.log("Mag:", mag.reading.x, ",", mag.reading.y, ",", mag.reading.z);
            //console.log("Accel:", accel.reading.x, ",", accel.reading.y, ",", accel.reading.z);

            var accelVec = [accel.reading.x, accel.reading.y, accel.reading.z]
            var magEast = crossProduct([mag.reading.x, mag.reading.y, mag.reading.z], accelVec)
            var magNorth = crossProduct(accelVec, magEast)

            magEast = normVec(magEast)
            magNorth = normVec(magNorth)

            var deviceHeading = [0., 1., -1.] //This is for portrait orientation on android
            deviceHeading = normVec(deviceHeading)

            var dotWithEast = dotProduct(deviceHeading, magEast)
            var dotWithNorth = dotProduct(deviceHeading, magNorth)
            var bearingRad = Math.atan2(dotWithEast, dotWithNorth)
            var bearingDeg = bearingRad * 180. / Math.PI
            //console.log("bearingDeg:", bearingDeg);

            baseCompass.magChange(bearingDeg)
            realCompass = 1
        }
    }

    Accelerometer
    {
        id: accel
        dataRate: 5
        active: true
    }

    function crossProduct(a, b) {

        // Check lengths
        if (a.length != 3 || b.length != 3) {
            return;
        }

        return [a[1]*b[2] - a[2]*b[1],
              a[2]*b[0] - a[0]*b[2],
              a[0]*b[1] - a[1]*b[0]];

    }

    function normVec(a) {
        var compSq = 0.
        for(var i=0;i<a.length;i++)
            compSq += Math.pow(a[i], 2)
        var mag = Math.pow(compSq, 0.5)
        if(mag == 0.) return
        var out = []
        for(var i=0;i<a.length;i++)
            out.push(a[i]/mag)
        return out
    }

    function dotProduct(a, b)
    {
        if (a.length != b.length) return;
        var comp = 0.
        for(var i=0;i<a.length;i++)
            comp += a[i] * b[i]
        return comp
    }


}

