#include <QApplication>
#include <QQmlApplicationEngine>
#include "slippytile.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    engine.addImageProvider(QLatin1String("tiles"), new class TileImageProvider);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
