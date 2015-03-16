#include "slippytile.h"
#include <QThread>
#include <QQmlContext>
#include <QtQuick/qsgnode.h>
#include <QtQuick/qsgflatcolormaterial.h>

//http://www.qtcentre.org/threads/1483-Qt4-How-to-load-Url-image-into-QImage
//http://portal.bluejack.binus.ac.id/tutorials/qtquick20application-qmlandcintegration

FileDownloader::FileDownloader(QQmlContext * ctx) : QObject()
{
    manager = new QNetworkAccessManager(this);
}

FileDownloader::~FileDownloader()
{

}

void FileDownloader::go(QString url)
{
    qDebug()<<"go\n";
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    manager->get(request);
    connect(manager,SIGNAL(finished(QNetworkReply*)),this,SLOT(fileDownloaded(QNetworkReply*)));
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
    //QVariant QQmlContext::contextProperty(const QString & name);

    if (size)
        *size = QSize(width, height);
    QPixmap pixmap(requestedSize.width() > 0 ? requestedSize.width() : width,
                   requestedSize.height() > 0 ? requestedSize.height() : height);
    pixmap.fill(QColor(id).rgba());

    return pixmap;
}

//****************************************************

BezierCurve::BezierCurve(QQuickItem *parent)
    : QQuickItem(parent)
    , m_p1(0, 0)
    , m_p2(1, 0)
    , m_p3(0, 1)
    , m_p4(1, 1)
    , m_segmentCount(32)
{
    setFlag(ItemHasContents, true);
}

BezierCurve::~BezierCurve()
{
}

void BezierCurve::setP1(const QPointF &p)
{
    if (p == m_p1)
        return;

    m_p1 = p;
    emit p1Changed(p);
    update();
}

void BezierCurve::setP2(const QPointF &p)
{
    if (p == m_p2)
        return;

    m_p2 = p;
    emit p2Changed(p);
    update();
}

void BezierCurve::setP3(const QPointF &p)
{
    if (p == m_p3)
        return;

    m_p3 = p;
    emit p3Changed(p);
    update();
}

void BezierCurve::setP4(const QPointF &p)
{
    if (p == m_p4)
        return;

    m_p4 = p;
    emit p4Changed(p);
    update();
}

void BezierCurve::setSegmentCount(int count)
{
    if (m_segmentCount == count)
        return;

    m_segmentCount = count;
    emit segmentCountChanged(count);
    update();
}

QSGNode *BezierCurve::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    QSGGeometryNode *node = 0;
    QSGGeometry *geometry = 0;

    if (!oldNode) {
        node = new QSGGeometryNode;
        geometry = new QSGGeometry(QSGGeometry::defaultAttributes_Point2D(), m_segmentCount);
        geometry->setLineWidth(2);
        geometry->setDrawingMode(GL_LINE_STRIP);
        node->setGeometry(geometry);
        node->setFlag(QSGNode::OwnsGeometry);
        QSGFlatColorMaterial *material = new QSGFlatColorMaterial;
        material->setColor(QColor(255, 0, 0));
        node->setMaterial(material);
        node->setFlag(QSGNode::OwnsMaterial);
    } else {
        node = static_cast<QSGGeometryNode *>(oldNode);
        geometry = node->geometry();
        geometry->allocate(m_segmentCount);
    }

    QRectF bounds = boundingRect();
    QSGGeometry::Point2D *vertices = geometry->vertexDataAsPoint2D();
    for (int i = 0; i < m_segmentCount; ++i) {
        qreal t = i / qreal(m_segmentCount - 1);
        qreal invt = 1 - t;

        QPointF pos = invt * invt * invt * m_p1
                    + 3 * invt * invt * t * m_p2
                    + 3 * invt * t * t * m_p3
                    + t * t * t * m_p4;

        float x = bounds.x() + pos.x() * bounds.width();
        float y = bounds.y() + pos.y() * bounds.height();

        vertices[i].set(x, y);
    }
    node->markDirty(QSGNode::DirtyGeometry);

    return node;
}
