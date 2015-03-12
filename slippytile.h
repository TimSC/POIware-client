#ifndef SLIPPYTILE_H
#define SLIPPYTILE_H

#include <QQuickImageProvider>

class ColorImageProvider : public QQuickImageProvider
{
public:
    ColorImageProvider();

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // SLIPPYTILE_H

