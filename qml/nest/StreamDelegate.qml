// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Component {
    id: streamEntry

    Rectangle {
        id: streamItemContainer
        width: streamList.width
        height: message.split("\n").length * 10 + 50
        color: "transparent"

        ListView.onAdd: SequentialAnimation  {
            PropertyAction { target: streamItemContainer; property: "height"; value: 0 }
            NumberAnimation { target: streamItemContainer; property: "height"; to: message.split("\n").length * 10 + 50; duration: 250; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            id: streamEntryBackground
            anchors.fill: parent
            color: "grey"
            opacity:.3
        }

        StyledText {
            text: message
            font.family: "Helvetica"
            x: thumbnail.width + 5
            font.pixelSize: 15
            color: "white"
            wrapMode: Text.Wrap
            width: parent.width - x
            textFormat: Text.RichText
            anchors.verticalCenter: parent.verticalCenter
            onLinkActivated: Qt.openUrlExternally(link)
        }


        Text {
            text: friendlyTime
            color: "lightgray"
            x: streamEntryBackground.width - width
            font.pixelSize: streamEntry.height - 10
            wrapMode: Text.Wrap
            y: parent.height - height
        }

        Image {
            id: thumbnail
            source: imageSource
            width: 48
            height: 48
            anchors.verticalCenter: parent.verticalCenter

        }

    }

}
