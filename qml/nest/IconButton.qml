import QtQuick 1.1

Rectangle {
    property alias source : icon.source

    id:iconButton
    color: "transparent"
    width: 60
    height: 60

    Rectangle {
        id: frame
        radius: 10
        anchors.fill: parent
        color: "transparent"
        opacity: 0
        border.width: 2
        Behavior on opacity {
            SequentialAnimation {
                NumberAnimation {easing.type: Easing.InOutQuad; duration: 300}

            }
        }
    }



    Image {
        id: icon
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        smooth: true

        MouseArea {
            id:mouse
            anchors.fill: parent
            hoverEnabled: true

            onHoveredChanged: {
                if (containsMouse)
                {
                    frame.opacity = 1
                } else {
                    frame.opacity = 0
                }
            }
        }

    }
}
