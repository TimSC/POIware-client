#ifndef SLIPPYTILE_H
#define SLIPPYTILE_H

#include <QQuickImageProvider>
#include <QNetworkAccessManager>
#include <QNetworkReply>

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

    int Go(QUrl imageUrl, QObject *parent = 0);

    virtual ~FileDownloader();

    QByteArray downloadedData() const;

signals:
        void downloaded();

private slots:

    void fileDownloaded(QNetworkReply* pReply);

private:



    QByteArray m_DownloadedData;

};

#endif // SLIPPYTILE_H

