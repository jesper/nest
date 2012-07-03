import QtQuick 1.1

Rectangle {
    id: container
    property alias text : text.text
    property alias echoMode : input.echoMode
    property alias input : input
    property alias disabled : disabled.visible


    border.color: "black"
    border.width: 1

    gradient: Gradient {
        GradientStop { position: 0.0; color: "white" }
        GradientStop { position: 1.0; color: "lightsteelblue" }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            input.focus = true;
        }
    }

    smooth: true
    radius: 7

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

    Text {
        id: text
        color: "#6E7678"
        font.family: "Helvetica"
        font.pixelSize: (container.height) - (container.height/1.5)
        x: 5
        opacity:.5
        anchors.centerIn: parent
    }

    TextInput {
        id: input
        passwordCharacter: "●"
        x: 5
        color: "#304C53"
        font.family: "Helvetica"
        anchors.centerIn: parent
        width: parent.width - (container.height/3)
        font.pixelSize: text.font.pixelSize
        horizontalAlignment: TextInput.AlignHCenter
        selectByMouse: true
        onFocusChanged: {
            text.visible = !focus

            if (input.text.length != 0)
                text.visible = false;
        }
    }
}
