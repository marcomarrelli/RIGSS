import QtQuick 2.15
import QtQuick.Controls 2.15

import QtLocation 5.15
import QtPositioning 5.15

import QtGraphicalEffects 1.12

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: gasStation

    property bool simulated: false

    property real size: 12
    property color color: gasStation.simulated ? "#89FC00" : "#FFF200"

    signal clicked()

    width: gasStation.size
    height: gasStation.size

    Rectangle {
        anchors.fill: parent

        radius: gasStation.size/4
        color: Theme.border
    }
    Controls.Label {
        anchors.fill: parent

        font { pointSize: -1; pixelSize: gasStation.height-1; bold: true; family: "Phosphor" }
        antialiasing: true
        color: gasStation.color
        text: Utils.getIcon(0xE318)
    }
    MouseArea {
        anchors.fill: parent

        onClicked: gasStation.clicked()
    }
}