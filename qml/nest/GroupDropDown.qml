import QtQuick 1.1

Item {

    property bool expanded: false
    width: parent.width
    height: expanded ? dropDownListView.count * 50 + 25 : 50
    Behavior on height {
        SequentialAnimation {
            NumberAnimation {easing.type: Easing.InOutQuad; duration: 300}
        }
    }

    Component {
        id: groupDelegate

        Rectangle {
            height: 50
            width: parent.width
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: .7
                radius: 5
            }

            Image {
                id: groupImage
                source: imageSource
                height: parent.height - 5
                width: parent.height - 5
                anchors.verticalCenter: parent.verticalCenter
                x: 4
            }

            StyledText {
                x: groupImage.x + groupImage.width + 2
                color: "white"
                text: groupTitle
                font.pixelSize: parent.height / 2
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                anchors.fill: parent

                onClicked:  {
                    if (index != 0)
                    {
                        signal_groupClicked(index)
                    }

                    expanded = !expanded
                }
            }
        }
    }

    ListView {
        id: dropDownListView
        anchors.fill: parent
        model: groupModel
        delegate: groupDelegate
        clip: true
        spacing: 2
    }
    /*
    Image {
        id: dropDownButton
        x: parent.width - width
        z: dropDownListView.z + 1
        height: 50
        width: 50
        visible: !expanded
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        smooth: true
        source: "qrc:/images/login.svg"
        rotation: 90

        MouseArea {
            anchors.fill: parent

            onClicked: {
                expanded = true
            }
        }
    }
    */
}
