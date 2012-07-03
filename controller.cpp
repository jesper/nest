#include "controller.h"
#include <QGraphicsObject>
#include <QDebug>
#include <QDialog>
#include <QTimer>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkCookieJar>
#include <QByteArray>
#include <QScriptValueIterator>


Controller::Controller(QObject *parent) :
    QObject(parent)
{
    m_groupModel = new CustomItemModel();
    m_groupModel->setSortRole(GroupRoles::SortRole);

    m_streamModel = new CustomItemModel();

    QHash<int, QByteArray> roleNames = m_streamModel->roleNames();
    roleNames[StreamRoles::ImageSourceRole] = "imageSource";
    roleNames[StreamRoles::TimestampRole] = "timestamp";
    roleNames[StreamRoles::FriendlyTimeRole] = "friendlyTime";
    roleNames[StreamRoles::MessageRole] = "message";
    roleNames[StreamRoles::URIRole] = "uri";

    m_streamModel->setRoles(roleNames);

    roleNames.clear();
    roleNames[GroupRoles::ImageSourceRole] = "imageSource";
    roleNames[GroupRoles::GroupIDRole] = "groupID";
    roleNames[GroupRoles::GroupTitleRole] = "groupTitle";
    roleNames[GroupRoles::SortRole] = "sort";

    m_groupModel->setRoles(roleNames);

    m_viewer = new QmlApplicationViewer();
    m_viewer->setWindowTitle("Nest");

    m_viewer->rootContext()->setContextProperty("streamModel", m_streamModel);
    m_viewer->rootContext()->setContextProperty("groupModel", m_groupModel);

    m_viewer->setMainQmlFile(QLatin1String("qml/nest/main.qml"));
    m_viewer->setWindowIcon(QIcon(":images/chat.svg"));
    m_viewer->showExpanded();

    m_browser = new QWebView(m_viewer);
    m_browser->setVisible(false);

    QWebSettings::globalSettings()->setAttribute(QWebSettings::AutoLoadImages, false);

    QObject *rootObject = dynamic_cast<QObject*>(m_viewer->rootObject());
    connect(rootObject, SIGNAL(signal_login(QString, QString)), this, SLOT(slot_login(QString, QString)));
    connect(rootObject, SIGNAL(signal_postMessage(QString)), this, SLOT(slot_postMessage(QString)));
    connect(rootObject, SIGNAL(signal_getLatestPosts()), this, SLOT(slot_getLatestPosts()));
    connect(rootObject, SIGNAL(signal_groupClicked(int)), this, SLOT(slot_groupClicked(int)));

    connect(this, SIGNAL(loginSuccess()), rootObject, SLOT(loginSuccess()));
    connect(this, SIGNAL(signal_loginStatusAuthenticating()), rootObject, SLOT(slot_loginStatusAuthenticating()));
    connect(this, SIGNAL(signal_loginStatusLoadingStream()), rootObject, SLOT(slot_loginStatusLoadingStream()));

    connect(this, SIGNAL(signal_positionStreamTop()), rootObject, SLOT(slot_positionStreamTop()));
    connect(this, SIGNAL(signal_loginFailed(QVariant)), rootObject, SLOT(slot_loginFailed(QVariant)));

    connect(this, SIGNAL(groupLoadedSuccess()), rootObject, SLOT(groupLoadedSuccess()));

    m_sysTray = new QSystemTrayIcon(this);
    m_sysTray->setIcon(QIcon(":images/chat.svg"));
    m_sysTray->show();
    connect(m_sysTray, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), this, SLOT(slot_sysTrayClicked()));
}

void Controller::slot_groupClicked(int index)
{
    qDebug() << "slot_groupClicked(" << QString::number(index) << ")";

    QStandardItem *item = m_groupModel->takeRow(index).first();
    m_groupModel->sort(0);
    m_groupModel->insertRow(0, item);

    m_streamModel->clear();

    slot_getLatestPosts();
}

void Controller::slot_sysTrayClicked()
{
    m_viewer->setVisible(!m_viewer->isVisible());
}

void Controller::slot_login(QString email, QString password)
{
    qDebug() << "slot_login(" << email << ")";
    m_email = email;
    m_password = password;
    connect(m_browser, SIGNAL(loadFinished(bool)), this, SLOT(slot_loginPageLoaded()));

    m_browser->setUrl(QUrl("https://www.mendeley.com/login/"));
}

QWebElement Controller::browserDocumentElement()
{
    return m_browser->page()->mainFrame()->documentElement();
}

void Controller::slot_loginPageLoaded()
{
    qDebug() << "slot_loginPageLoaded()";
    m_browser->disconnect();

    emit signal_loginStatusAuthenticating();

    m_csrfToken = browserDocumentElement().evaluateJavaScript("$.cookie('csrf_token')").toString();
    QString loginString = "csrf_token=" + m_csrfToken +"&loginSessionKey=&" +
            "email=" + m_email + "&password=" + QUrl::toPercentEncoding(m_password);

    connect(m_browser, SIGNAL(loadFinished(bool)), this, SLOT(slot_loginCompleted(bool)));

    manualBrowserRequest("https://www.mendeley.com/login/",
                         QNetworkAccessManager::PostOperation,
                         loginString);
}


void Controller::slot_loginCompleted(bool ok)
{
    qDebug() << "slot_loginCompleted()";
    m_browser->disconnect();

    if (!ok)
    {
        emit signal_loginFailed("Login failed - server seems down.");
        return;
    }

    if (m_browser->findText("Incorrect details. Forgot your password?"))
    {
        emit signal_loginFailed("Incorrect username/password");
        return;
    }

    connect(m_browser, SIGNAL(loadFinished(bool)), this, SLOT(slot_groupListLoaded()));
    m_browser->setUrl(QUrl("https://www.mendeley.com/groups/"));
}

void Controller::slot_groupListLoaded()
{
    m_browser->disconnect();

    QWebElementCollection elements = browserDocumentElement().findAll("article.member");

    foreach (QWebElement element, elements) {
        if (element.classes().contains("group-type-institution"))
        {
            //Skip MIE groups
            continue;
        }

        QStandardItem *item = new QStandardItem();
        QString groupTitle = element.findFirst("div.title a").toPlainText();
        item->setData(groupTitle, GroupRoles::GroupTitleRole);
        item->setData(groupTitle.toUpper(), GroupRoles::SortRole);

        QString id = element.findFirst("div.title a").attribute("href");
        id.replace(QRegExp("http://www.mendeley.com/groups/(.*)/.*/"), "\\1");
        item->setData(id, GroupRoles::GroupIDRole);
        item->setData(element.findFirst("a.thumb img").attribute("src"), GroupRoles::ImageSourceRole);
        m_groupModel->appendRow(item);
    }

    m_groupModel->sort(0);

    connect(m_browser->page()->networkAccessManager(), SIGNAL(finished(QNetworkReply*)), this, SIGNAL(loginSuccess()));

    slot_getLatestPosts();
    emit signal_loginStatusLoadingStream();
}

void Controller::slot_getLatestPosts()
{
    qDebug() << "slot_getLatestPosts()";

    QNetworkAccessManager* nam = m_browser->page()->networkAccessManager();

    connect(nam, SIGNAL(finished(QNetworkReply*)), this, SLOT(slot_groupLoaded(QNetworkReply*)));
    QNetworkRequest request;
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    request.setRawHeader(QByteArray("X-CSRF-Token"), m_csrfToken.toAscii());
    request.setRawHeader(QByteArray("X-Requested-With"), QByteArray("XMLHttpRequest"));
    request.setUrl(QUrl("http://www.mendeley.com/feed/group/" + getcurrentGroupID() + "/?timestamp=" + QString::number(QDateTime::currentMSecsSinceEpoch()) + "&outputFormat=json"));
    nam->get(request);
}

bool Controller::modelHasMessageWithURI(QString uri)
{
    for (int i = 0; i < m_streamModel->rowCount(); ++i)
    {
        if (m_streamModel->item(i)->data(StreamRoles::URIRole) == uri)
        {
            return true;
        }
    }

    return false;
}

// Need to use QNetworkReply because we can't get the raw JSON any othe way.
// toPlainText && accessing attributes (using the browser) makes various small changes to the source data
// (converting \&amp; to " for example - this breaks parsing later)
void Controller::slot_groupLoaded(QNetworkReply *reply)
{
    qDebug() << "slot_groupLoaded()";

    // FIXME check for broken networkreply / errors

    m_browser->page()->networkAccessManager()->disconnect(this);

    QString result(reply->readAll());

    QScriptValue sc;
    QScriptEngine engine;
    sc = engine.evaluate(result);

    //FIXME do something with this error handling
    if (engine.hasUncaughtException()) {
        int line = engine.uncaughtExceptionLineNumber();
        qDebug() << "uncaught exception at line" << line << ":" << sc.toString();
    }


    QScriptValueIterator it(sc);
    it.toBack();
    it.previous();

    // Need to iterate in reverse order since the entries come in decending order
    while (it.hasPrevious())
    {
        it.previous();

        QString uri = it.value().property("uri").toString();

        if (modelHasMessageWithURI(uri))
        {
            continue;
        }

        QString message = it.value().property("text").toString();

      /* // Not sure if I should strip down to plaintext...
         QTextDocument doc;
        doc.setHtml(message);

        message = doc.toPlainText(); */

        if (message.length() > 270)
        {
            message = message.left(270);
        }

        QStandardItem *item = new QStandardItem();
        item->setData(it.value().property("profile").property("photo").toString(), StreamRoles::ImageSourceRole);
        item->setData(message, StreamRoles::MessageRole);
        item->setData(it.value().property("modificationTime").toString(), StreamRoles::TimestampRole);
        item->setData(it.value().property("uri").toString(), StreamRoles::URIRole);
        QDateTime time = QDateTime::fromTime_t(it.value().property("modificationTime").toInteger());

        item->setData(time.toString("hh:mm (dd/mm/yy)"), StreamRoles::FriendlyTimeRole);
        m_streamModel->insertRow(0, item);
        emit signal_positionStreamTop();
    }


    emit groupLoadedSuccess();
}

void Controller::manualBrowserRequest(const QString &url,  QNetworkAccessManager::Operation operation, const QString &body)
{
    QNetworkRequest request;
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    request.setRawHeader(QByteArray("X-CSRF-Token"), m_csrfToken.toAscii());
    request.setRawHeader(QByteArray("X-Requested-With"), QByteArray("XMLHttpRequest"));
    request.setUrl(QUrl(url));
    m_browser->load(request, operation, body.toAscii());
}

void Controller::slot_postMessage(QString message)
{
    qDebug() << "slot_postMessage(" << message << ")";

    connect(m_browser, SIGNAL(loadFinished(bool)), this, SLOT(slot_messagePosted()));
    manualBrowserRequest("https://www.mendeley.com/feed/groupStatusUpdate/",
                         QNetworkAccessManager::PostOperation,
                         "update=" + QUrl::toPercentEncoding(message) +"&groupId=" + getcurrentGroupID() + "&version=4");
}

QString Controller::getcurrentGroupID()
{
    return m_groupModel->item(0)->data(GroupRoles::GroupIDRole).toString();
}

void Controller::slot_messagePosted()
{
    qDebug() << "slot_MessagePosted";
    m_browser->disconnect();
    slot_getLatestPosts();
}
