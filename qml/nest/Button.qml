import QtQuick 1.1

Rectangle {
    id: button
    property alias text : text.text
    property alias showIcon : icon.visible
    property alias disabled : disabled.visible


    border.color: "black"
    border.width: 2
    gradient: Gradient {
        GradientStop { position: 0.0; color: "white" }
        GradientStop { position: 1.0; color: "lightblue" }
    }

    Rectangle {
        z: parent.z + 5
        id:disabled
        visible: false
        anchors.fill: parent
        opacity: 0.2
        color: "black"
        MouseArea {
            anchors.fill: parent
        }
    }

    smooth: true
    radius: 7

    Text {
        id: text
        color: "black"
        text: "Login"
        font.pixelSize: (button.height) - (button.height/2)
        anchors.centerIn: parent
        font.family: "Helvetica"
        font.bold: true
        x: 5
    }

    Image
    {
        id: icon
        source: "qrc:/images/login.svg"
        anchors.verticalCenter: parent.verticalCenter
        x: button.width - width - 5
        sourceSize.height: button.height * .7
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return || event.key == Qt.Key_Space) {
            state = "pressed"
        }
    }

    onFocusChanged: {
        if (focus)
        {
            border.width = 3
        } else {
            border.width = 2
        }
    }

    MouseArea {
        id:mouse
        anchors.fill: parent

        hoverEnabled: true
        onPressed: {
            parent.state = "pressed";
        }

        onHoveredChanged: {
            if (containsMouse)
            {
                border.width = 3
            } else {
                border.width = 2
            }
        }
    }

    states: [
        State {
            name: "pressed"
            PropertyChanges { target: button; scale: 1.02 }
        }
    ]
    transitions: Transition {
        SequentialAnimation {
            NumberAnimation { properties: "scale"; duration: 200; easing.type: Easing.InOutQuad }
            ScriptAction {
                script: button.state = ""
            }
        }
    }

}
