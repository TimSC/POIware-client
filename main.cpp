#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "slippytile.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QQmlContext *ctxt = engine.rootContext();
    class FileDownloader mov(ctxt);

    engine.addImageProvider(QLatin1String("tiles"), new class TileImageProvider);
    ctxt->setContextProperty("FileDownloader",&mov);

    qmlRegisterType<BezierCurve>("CustomGeometry", 1, 0, "BezierCurve");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
