import QtQuick 2.15
import QtQuick.Templates 2.15 as T

import ApplicationSettings 1.0

import "../../logic/utils.js" as Utils

T.Label {
    id: label

    property real fontSize: 12
    property string fontFamily: ""

    property bool bold: false

    property color textColor: Theme.text
    property color highlightedColor: Theme.highlight
    
    width: 200; height: 100

    font {
        pointSize: label.fontSize
        bold: label.bold
        family: label.fontFamily
    }
    color: label.textColor

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}