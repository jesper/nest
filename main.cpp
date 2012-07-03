#include <QApplication>

#include "controller.h"

int main(int argc, char *argv[])
{
    QApplication::setGraphicsSystem("raster");
    QApplication app(argc, argv);

    QCoreApplication::setApplicationName("Nest");

    Controller c;
    return app.exec();
}
