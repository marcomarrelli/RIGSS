import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Templates 2.15 as T

import ApplicationSettings 1.0

import "." as Controls
import "../../logic/utils.js" as Utils

T.ComboBox {
    id: combobox
    
    property real radius: 5
    property real borderWidth: 1
    property real fontSize: 12

    property bool bold: false

    property color textColor: Theme.text
    property color backgroundColor: Theme.light
    property color highlightedColor: Theme.highlight
    property color borderColor: Theme.border

    rightPadding: width/25
    hoverEnabled: true

    delegate: ItemDelegate {
        width: combobox.width
        highlighted: combobox.highlightedIndex === index
        contentItem: Controls.Label {
            text: modelData
            color: combobox.textColor
            font.pointSize: combobox.fontSize
            elide: Text.ElideRight
        }
        background: Rectangle {
            color: highlighted ? combobox.highlightedColor : combobox.backgroundColor
            radius: combobox.radius

            border {
                color: combobox.borderColor
                width: combobox.borderWidth
            }
        }
    }

    indicator: Canvas {
        id: canvas

        x: combobox.width-(width+combobox.rightPadding)
        y: (combobox.availableHeight-height)/2

        width: combobox.width/25; height: combobox.height/4
        
        onPaint: {
            var context = getContext("2d")
            
            context.reset()
            context.moveTo(0, 0)
            context.lineTo(width, 0)
            context.lineTo(width / 2, height)
            context.closePath()
            context.fillStyle = combobox.pressed ? Theme.light : Theme.text
            context.fill()
        }
    }

    contentItem: Controls.Label {
        leftPadding: 0
        rightPadding: combobox.indicator.width + combobox.spacing

        text: combobox.displayText
        font.pointSize: combobox.fontSize
        color: combobox.pressed ? Theme.light : Theme.text
        elide: Text.ElideRight
    }

    background: Rectangle {
        color: combobox.hovered ? combobox.highlightedColor : combobox.backgroundColor
        radius: combobox.radius

        border {
            color: combobox.borderColor
            width: combobox.borderWidth
        }
    }

    popup: Popup {
        y: combobox.height - 1
        width: combobox.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: combobox.popup.visible ? combobox.delegateModel : null
            currentIndex: combobox.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }
        background: Rectangle {
            color: combobox.backgroundColor
            radius: combobox.radius

            border {
                color: combobox.borderColor
                width: combobox.borderWidth
            }
        }
    }
}

/*
T.combobox {
    id: combobox

    property real radius: 5
    property real borderWidth: 1
    property real fontSize: combobox.iconCode === "" ? 12 : 20

    property string iconCode: ""
    property bool bold: false

    property color textColor: Theme.text
    property color backgroundColor: Theme.light
    property color highlightedColor: Theme.highlight
    property color borderColor: Theme.border

    width: 200; height: 100
    hoverEnabled: true

    background: Rectangle {
        color: combobox.hovered ? combobox.highlightedColor : combobox.backgroundColor
        radius: combobox.radius

        border {
            color: combobox.borderColor
            width: combobox.borderWidth
        }
    }

    contentItem: Label {
        text: combobox.iconCode === "" ? combobox.text : combobox.iconCode
        color: combobox.textColor

        font {
            pointSize: combobox.fontSize
            bold: combobox.bold
            family: combobox.iconCode === "" ? combobox.font.family : "Phosphor"
        }

        antialiasing: true
        
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
*/
