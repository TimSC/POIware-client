#include <QApplication>
#include <QQmlApplicationEngine>
#include "slippytile.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    engine.addImageProvider(QLatin1String("colors"), new class ColorImageProvider);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
