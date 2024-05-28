import QtQuick 2.15
import QtQuick.Templates 2.15 as T

import ApplicationSettings 1.0

import "../../logic/utils.js" as Utils

T.Button {
    id: button

    property real radius: 5
    property real borderWidth: 1
    property real fontSize: 12

    property bool bold: false

    property color textColor: Theme.text
    property color backgroundColor: Theme.light
    property color highlightedColor: Theme.highlight
    property color borderColor: Theme.border

    width: 200; height: 100
    hoverEnabled: true

    background: Rectangle {
        color: button.hovered ? button.highlightedColor : button.backgroundColor
        radius: button.radius

        border {
            color: button.borderColor
            width: button.borderWidth
        }
    }

    contentItem: Label {
        text: button.text
        color: button.textColor

        font {
            pointSize: button.fontSize
            bold: button.bold
        }

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
