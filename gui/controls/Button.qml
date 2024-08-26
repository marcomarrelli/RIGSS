import QtQuick 2.15
import QtQuick.Templates 2.15 as T

import ApplicationSettings 1.0

import "../../logic/utils.js" as Utils

T.Button {
    id: button

    property real radius: 5
    property real borderWidth: 1
    property real fontSize: button.iconCode === "" ? 12 : 20

    property string iconCode: ""
    property bool bold: false

    property color textColor: Theme.text
    property color backgroundColor: Theme.light
    property color highlightedColor: Theme.highlight
    property color borderColor: Theme.border

    width: 200; height: 100
    opacity: enabled ? 1 : 0.75
    hoverEnabled: true

    background: Rectangle {
        color: button.checked || button.hovered ? button.highlightedColor : button.backgroundColor
        radius: button.radius

        border {
            color: button.borderColor
            width: button.borderWidth
        }
    }

    contentItem: Label {
        text: button.iconCode === "" ? button.text : button.iconCode
        color: button.textColor

        font {
            pointSize: button.fontSize
            bold: button.bold
            family: button.iconCode === "" ? button.font.family : "Phosphor"
        }

        antialiasing: true
        
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
