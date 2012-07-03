#include "customitemmodel.h"

CustomItemModel::CustomItemModel(QObject *parent) :
    QStandardItemModel(parent)
{
}

void CustomItemModel::setRoles(const QHash<int, QByteArray> &roleNames)
{
    setRoleNames(roleNames);
}
