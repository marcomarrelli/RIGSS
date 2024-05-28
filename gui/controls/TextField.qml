import QtQuick 2.15
import QtQuick.Controls 2.15 as C

import ApplicationSettings 1.0

import "../../logic/utils.js" as Utils

C.TextField {
    id: textfield

    property real radius: 5
    property real borderWidth: 1
    property real fontSize: 12

    property bool bold: false

    property color textColor: Theme.text
    property color backgroundColor: Theme.light
    property color highlightedColor: Theme.highlight
    property color placeholderColor: Theme.isDarkMode() ? Qt.lighter(Theme.text, 1.25) : Qt.darker(Theme.text, 1.25)
    property color borderColor: Theme.border

    property string placeholder: ""

    width: 500
    height: 200
    hoverEnabled: true

    background: Rectangle {
        color: textfield.backgroundColor
        radius: textfield.radius

        border {
            color: textfield.borderColor
            width: textfield.borderWidth
        }
    }

    font.pointSize: textfield.fontSize
    font.bold: textfield.bold
    color: textfield.hovered && textfield.hoverEnabled && !textfield.focus ? textfield.highlightedColor : textfield.textColor

    placeholderText: textfield.placeholder
    placeholderTextColor: textfield.placeholderColor
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignLeft

    Keys.onEnterPressed: textfield.editingFinished()

    onFocusChanged: textfield.placeholderText = textfield.focus ? "" : textfield.placeholder
    onEditingFinished: textfield.focus = false
}
