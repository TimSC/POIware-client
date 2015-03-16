#ifndef SLIPPYTILE_H
#define SLIPPYTILE_H

#include <QQuickImageProvider>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QtQuick/QQuickItem>

class TileImageProvider : public QQuickImageProvider
{
public:
    TileImageProvider();

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
};

class FileDownloader : public QObject
{
    Q_OBJECT
public:

    explicit FileDownloader(QQmlContext * ctx);

    Q_INVOKABLE void go(QString id);

    virtual ~FileDownloader();

    QByteArray downloadedData() const;

signals:
        void downloaded();

private slots:

    void fileDownloaded(QNetworkReply* pReply);

private:

    QByteArray m_DownloadedData;
    QNetworkAccessManager *manager;

};

class BezierCurve : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QPointF p1 READ p1 WRITE setP1 NOTIFY p1Changed)
    Q_PROPERTY(QPointF p2 READ p2 WRITE setP2 NOTIFY p2Changed)
    Q_PROPERTY(QPointF p3 READ p3 WRITE setP3 NOTIFY p3Changed)
    Q_PROPERTY(QPointF p4 READ p4 WRITE setP4 NOTIFY p4Changed)

    Q_PROPERTY(int segmentCount READ segmentCount WRITE setSegmentCount NOTIFY segmentCountChanged)

public:
    BezierCurve(QQuickItem *parent = 0);
    ~BezierCurve();

    QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *);

    QPointF p1() const { return m_p1; }
    QPointF p2() const { return m_p2; }
    QPointF p3() const { return m_p3; }
    QPointF p4() const { return m_p4; }

    int segmentCount() const { return m_segmentCount; }

    void setP1(const QPointF &p);
    void setP2(const QPointF &p);
    void setP3(const QPointF &p);
    void setP4(const QPointF &p);

    void setSegmentCount(int count);

signals:
    void p1Changed(const QPointF &p);
    void p2Changed(const QPointF &p);
    void p3Changed(const QPointF &p);
    void p4Changed(const QPointF &p);

    void segmentCountChanged(int count);

private:
    QPointF m_p1;
    QPointF m_p2;
    QPointF m_p3;
    QPointF m_p4;

    int m_segmentCount;
};

#endif // SLIPPYTILE_H

