#ifndef SLIPPYTILE_H
#define SLIPPYTILE_H

#include <QQuickImageProvider>

class TileImageProvider : public QQuickImageProvider
{
public:
    TileImageProvider();

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // SLIPPYTILE_H

