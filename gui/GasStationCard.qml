import QtQuick 2.15
import QtQuick.Controls 2.15

import QtLocation 5.15
import QtPositioning 5.15

import QtGraphicalEffects 1.12

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: card

    property var gasStation

    property color textColor: Theme.text
    property color backgroundColor: Theme.light
    property real radius: 12.5

    width: 100
    height: 50

    Rectangle {
        id: background

        anchors.fill: parent

        radius: card.radius
        color: card.backgroundColor
    }
    Controls.Label {
        id: cardName

        width: parent.width
        height: Utils.perc(parent.height, 15)
        anchors {
            top: parent.top; topMargin: 5
            left: parent.left; leftMargin: 5
        }

        text: gasStation ? gasStation.nome : "N/A"

        font {
            pointSize: 10
            bold: true
        }
        horizontalAlignment: Text.AlignLeft
    }
    Rectangle {
        // IMAGE
        height: Utils.perc(parent.height, 75)
        width: Utils.perc(parent.height, 75)

        anchors {
            bottom: parent.bottom; bottomMargin: 2.5
            left: parent.left; leftMargin: 5
        }
    }
}