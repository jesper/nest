import QtQuick 1.1

Rectangle {
    id: stream
    property bool animate: false;
    property alias streamList: streamList
    property alias messageInput: messageInput
    property bool showLoadingHeader: false
    property string loadingHeaderText: ""

    clip: true
    color: "transparent"

    Timer {
        id: time
        interval: 50; running: false; repeat: false
        onTriggered: { console.log("!!!Timer triggered!!") }
    }

    Behavior on x {
        enabled: animate;
        SequentialAnimation {
            NumberAnimation {easing.type: Easing.InOutQuad; duration: 300}
            ScriptAction {
                script: {
                    animate = false
                }
            }
        }
    }

    GroupDropDown
    {
        id: streamDropDown
        y: 5
        z: messageInput.z + 1
    }

    //FIXME Make TextEdit with linebreaks
    UserInput
    {
        id:messageInput
        anchors.horizontalCenter: parent.horizontalCenter
        y: streamDropDown.y + streamDropDown.height + 5
        width: parent.width - 20
        //wrapMode:  TextEdit.WordWrap
        height: 60
        text: "Type Message Here..."
        input.maximumLength: 141
        input.font.pixelSize: 20

        Keys.onPressed: {
            if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                postMessage(messageInput.input.text)
            }
        }

        Text {
            x: parent.width - 23
            y: parent.height - 15
            text: 141 - messageInput.input.text.length
            color: "grey"
            font.pixelSize: parent.height / 7
        }
    }

    ListView {
        id: streamList
        width: parent.width
        height: parent.height - y
        y: messageInput.y + messageInput.height + 5
        model: streamModel
        delegate: streamEntry
        spacing: 5
        clip: true
        header: streamListHeader

        onContentYChanged:
        {
            if (streamList.contentY < streamList.count * -12 - 60  && !showLoadingHeader)
            {
                showLoadingHeader = true
                loadingHeaderText = "Release to check for new posts ..."
            }
        }
        onMovementEnded: {
            if (showLoadingHeader)
            {
                loadingHeaderText = "Checking for new posts ..."
                signal_getLatestPosts();
            }
        }

    }

    Component
    {
        id: streamListHeader

        Item {
            height: showLoadingHeader ? 50 : 0;
            width: streamList.width

            Rectangle {
                width: parent.width
                height: parent.height

                color: "transparent"
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: .2

                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: parent.height / 3
                    text: loadingHeaderText
                    visible: showLoadingHeader
                }
            }

            Behavior on height {

                NumberAnimation {duration: 300}

            }

        }
    }


    StreamDelegate {
        id: streamEntry
    }
}
