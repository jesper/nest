#ifndef CUSTOMITEMMODEL_H
#define CUSTOMITEMMODEL_H

#include <QStandardItemModel>

class CustomItemModel : public QStandardItemModel
{
    Q_OBJECT
public:
    explicit CustomItemModel(QObject *parent = 0);
    void setRoles(const QHash<int, QByteArray> &roleNames);
    
signals:
    
public slots:
    
};

#endif // CUSTOMITEMMODEL_H
