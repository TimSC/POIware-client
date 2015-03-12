#include "slippytile.h"
#include <QThread>
#include <assert.h>

//http://www.qtcentre.org/threads/1483-Qt4-How-to-load-Url-image-into-QImage
//http://portal.bluejack.binus.ac.id/tutorials/qtquick20application-qmlandcintegration

QNetworkAccessManager *manager;

FileDownloader::FileDownloader(QQmlContext * ctx) : QObject()
{
    QNetworkRequest request;
    //this->ctxt = ctx;
    manager = new QNetworkAccessManager(this);
    request.setUrl(QUrl("http://imgs.xkcd.com/comics/new_products.png"));
    manager->get(request);
    connect(manager,SIGNAL(finished(QNetworkReply*)),this,SLOT(fileDownloaded(QNetworkReply*)));

}

FileDownloader::~FileDownloader()
{

}

void FileDownloader::fileDownloaded(QNetworkReply* pReply)
{
    qDebug()<<"fileDownloaded\n";
    m_DownloadedData = pReply->readAll();
    //emit a signal
    pReply->deleteLater();
    emit downloaded();
}

QByteArray FileDownloader::downloadedData() const
{
    return m_DownloadedData;
}

/* ************************************************* */

TileImageProvider::TileImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap TileImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    int width = 100;
    int height = 50;

    //class FileDownloader asyncRequest(QUrl("http://imgs.xkcd.com/comics/new_products.png"));
    //QThread::msleep(1000);

    if (size)
        *size = QSize(width, height);
    QPixmap pixmap(requestedSize.width() > 0 ? requestedSize.width() : width,
                   requestedSize.height() > 0 ? requestedSize.height() : height);
    pixmap.fill(QColor(id).rgba());

    return pixmap;
}
