import QtQuick 1.1

Rectangle {
    id: loginWindow
    color: "transparent"
    property alias errrorMessage: errorMessage.text
    property alias loginButton: loginButton
    property alias email: email
    property alias password: password

    Image {
        source: "qrc:/images/fork-me.png"
        smooth: true
        scale: .9
        x: parent.width - width + 7
        y: -10

        MouseArea {
            anchors.fill: parent

            onClicked:
            {
                Qt.openUrlExternally("http://www.github.com/jesper/nest");
            }
        }
    }

    StyledText {
        id: title
        y: parent.height/6
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: parent.width/2.5
        text: "Nest"
    }


    StyledText
    {
        id:motto
        z: 1
        y: title.y + title.height + 5
        anchors.horizontalCenter: parent.horizontalCenter

        text: "Stop. Collaborate and <i>Listen!</i>"
        font.pixelSize: parent.width/15
    }

    StyledText
    {
        id:errorMessage
        z: 1
        y: motto.y + motto.height + 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: "red"
        font.italic: true
        font.pixelSize: parent.width/18
    }

    UserInput
    {
        id:email
        anchors.horizontalCenter: parent.horizontalCenter
        y: (parent.height/8) * 5
        width: parent.width - 20
        height: parent.height/11
        text: "example@company.com"
        KeyNavigation.tab: password.input
        KeyNavigation.backtab: loginButton
    }

    UserInput
    {
        id:password
        anchors.horizontalCenter: parent.horizontalCenter
        y: email.height + email.y + 6
        width: parent.width - 20
        height: parent.height/11
        echoMode: TextInput.Password
        text: "password"

        KeyNavigation.tab: loginButton
        KeyNavigation.backtab: email.input

        Keys.onPressed: {
            if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                loginButton.state = "pressed";
            }
        }
    }

    Button
    {
        id:loginButton
        height: parent.height/11
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        y: password.y + password.height + 6

        KeyNavigation.tab: email.input
        KeyNavigation.backtab: password.input

        onStateChanged: {
            if (state == "pressed")
            {
                login(email.input.text, password.input.text);
            }
        }
    }

    StyledText {
        id: linkText
        y: parent.height - height - 10
        anchors.horizontalCenter: parent.horizontalCenter
        smooth: true
        text: "Dont have Mendeley? <u>Sign up here.</u>"
        font.pixelSize: parent.height/40

        MouseArea {
            id: linkTextMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                Qt.openUrlExternally("https://www.mendeley.com/join/?source=nest");
            }

            states: [
                State {
                    name: "Hovered"; when: linkTextMouseArea.containsMouse
                    PropertyChanges { target: linkText; scale: 1.01 }
                }
            ]
            transitions: [
                Transition {
                    NumberAnimation { properties: "scale"; duration: 1000; easing.type: Easing.OutElastic }
                }
            ]
        }
    }

    Behavior on x {
        SequentialAnimation {
            NumberAnimation {easing.type: Easing.InOutQuad; duration: 300}
            ScriptAction {
                script: {
                    if (x == -width) {
                        visible = false;
                    }
                }
            }
        }
    }
}
