#include "slippytile.h"

//http://www.qtcentre.org/threads/1483-Qt4-How-to-load-Url-image-into-QImage

TileImageProvider::TileImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap TileImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    int width = 100;
    int height = 50;

    nam = new QNetworkAccessManager(this);
    QObject::connect(nam, SIGNAL(finished(QNetworkReply*)),
    this, SLOT(finishedSlot(QNetworkReply*)));

    QUrl url("http://www.slowstop.com/images/uploads/YouTube_Logo.jpg");
    QNetworkReply* reply = nam->get(QNetworkRequest(url));

    /*if (size)
        *size = QSize(width, height);
    QPixmap pixmap(requestedSize.width() > 0 ? requestedSize.width() : width,
                   requestedSize.height() > 0 ? requestedSize.height() : height);
    pixmap.fill(QColor(id).rgba());*/

    return pixmap;
}

void http_new::finishedSlot(QNetworkReply *reply)
{
    // Reading attributes of the reply
    // e.g. the HTTP status code
    QVariant statusCodeV =
    reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);

    // Or the target URL if it was a redirect:
    QVariant redirectionTargetUrl =
    reply->attribute(QNetworkRequest::RedirectionTargetAttribute);

    // no error received?
    if (reply->error() == QNetworkReply::NoError)
    {
        // read data from QNetworkReply here
        QByteArray bytes = reply->readAll(); // bytes
        QPixmap pixmap;
        pixmap.loadFromData(bytes);
        ui.label->setPixmap(pixmap);
    }
    // Some http error received
    else
    {
        // handle errors here
    }

    // We receive ownership of the reply object
    // and therefore need to handle deletion.
    delete reply;
}
