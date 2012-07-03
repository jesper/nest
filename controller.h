#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QDeclarativeContext>
#include <QtWebKit/QWebView>
#include <QtWebKit/QWebFrame>
#include <QtWebKit/QWebElement>
#include <QStandardItemModel>
#include <QSystemTrayIcon>
#include <QNetworkReply>

#include "qmlapplicationviewer.h"
#include "customitemmodel.h"

struct StreamRoles {
    enum Roles {
        ImageSourceRole = Qt::UserRole + 1,
        TimestampRole,
        FriendlyTimeRole,
        MessageRole,
        URIRole
    };
};

struct GroupRoles {
    enum Roles {
        ImageSourceRole = Qt::UserRole + 1,
        GroupIDRole,
        GroupTitleRole,
        SortRole
    };
};

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QObject *parent = 0);

public slots:
    void slot_login(QString email, QString password);
    void slot_loginPageLoaded();
    void slot_loginCompleted(bool ok);
    void slot_groupLoaded(QNetworkReply *reply);
    void slot_postMessage(QString);
    void slot_messagePosted();
    void slot_getLatestPosts();
    void slot_groupClicked(int index);


private slots:
    void slot_sysTrayClicked();
    void slot_groupListLoaded();

signals:
    void loginSuccess();
    void groupLoadedSuccess();
    void signal_positionStreamTop();
    void signal_loginFailed(QVariant reason);
    void signal_loginStatusAuthenticating();
    void signal_loginStatusLoadingStream();

private:
    QWebElement browserDocumentElement();
    void manualBrowserRequest(const QString &url,  QNetworkAccessManager::Operation operation = QNetworkAccessManager::GetOperation, const QString &body = "");
    bool modelHasMessageWithURI(QString uri);
    QString getcurrentGroupID();


    QmlApplicationViewer *m_viewer;
    QWebView *m_browser;
    QString m_email;
    QString m_password;
    CustomItemModel *m_streamModel;
    CustomItemModel *m_groupModel;
    QString m_csrfToken;
    QString m_lastMessageId;
    QSystemTrayIcon *m_sysTray;
};

#endif // CONTROLLER_H
