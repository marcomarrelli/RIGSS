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
    property var gasStationData

    property color textColor: Theme.text
    property color backgroundColor: Theme.light
    property real radius: 12.5

    signal clicked(gasStation: var)

    width: 100
    height: 50

    Rectangle {
        id: background

        anchors.fill: parent

        border {
            width: 1
            color: Theme.border
        }
        radius: card.radius
        color: card.backgroundColor
    }

    Image { // IMAGE
        id: logo

        height: Utils.perc(parent.height, 60)
        width: Utils.perc(parent.height, 60)

        anchors {
            left: parent.left; leftMargin: 5
            bottom: parent.bottom; bottomMargin: 7
        }

        source: "data:image/svg+xml;utf8," + card.gasStationData.getLogo(card.gasStation.bandiera)
    }
    Controls.Label {
        id: name

        height: Utils.perc(parent.height, 12.5)
        anchors {
            top: parent.top; topMargin: 5
            left: parent.left; leftMargin: 5
            right: parent.right; rightMargin: 5
        }

        text: gasStation ? gasStation.nome ?? "N/A" : "N/A"

        font {
            pointSize: -1
            pixelSize: height
            bold: true
        }
        horizontalAlignment: Text.AlignLeft
    }
    Controls.Label {
        id: street

        height: Utils.perc(parent.height, 9)
        anchors {
            top: name.bottom; topMargin: 5
            left: parent.left; leftMargin: 5
            right: parent.right; rightMargin: 5
        }

        text: gasStation ? gasStation.via.slice(0, -6) ?? "N/A" : "N/A"
        
        font {
            pointSize: -1
            pixelSize: height
        }
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignLeft
    }
    Controls.Label {
        id: position

        height: Utils.perc(parent.height, 9)
        anchors {
            top: logo.top; topMargin: 1
            left: logo.right; leftMargin: 10
            right: parent.right; rightMargin: 5
        }

        text: gasStation ? ((gasStation.latitudine.toFixed(5).padStart(8, '0') ?? "N/A") + " - " + (gasStation.longitudine.toFixed(5).padStart(8, '0') ?? "N/A")) : "N/A - N/A"

        font {
            pointSize: -1
            pixelSize: height
        }
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignLeft
    }
    Controls.Label {
        id: place

        height: Utils.perc(parent.height, 9)
        anchors {
            top: position.bottom; topMargin: 7
            left: logo.right; leftMargin: 10
            right: parent.right; rightMargin: 5
        }

        text: gasStation ? ((gasStation.comune ?? "N/A") + ", " + (gasStation.provincia ?? "N/A") + ", " + (gasStation.cap ?? "N/A")) : "N/A, N/A, N/A"

        font {
            pointSize: -1
            pixelSize: height
        }
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignLeft
    }
    Controls.Label {
        id: type

        height: Utils.perc(parent.height, 9)
        anchors {
            top: place.bottom; topMargin: 7
            left: logo.right; leftMargin: 10
            right: parent.right; rightMargin: 5
        }

        text: gasStation ? gasStation.bandiera ?? "N/A" : "N/A"

        font {
            pointSize: -1
            pixelSize: height
        }
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignLeft
    }

    /*
    { CHECK SIMULAZIONE }
    */

    MouseArea {
        id: handler

        anchors.fill: parent

        hoverEnabled: true
        onClicked: card.clicked(card.gasStation)
        onEntered: background.border.color = Theme.highlight
        onExited: background.border.color = Theme.border
    }
}