import QtQuick 2.15

import ApplicationSettings 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: mainPage

    readonly property real radius: 25

    GasStationsMap {
        id: gasStationMap

        width: Utils.perc(parent.width, 70)

        anchors {
            top: parent.top; topMargin: 25
            bottom: parent.bottom; bottomMargin: 25
            left: parent.left; leftMargin: 25
        }

        mapRadius: mainPage.radius
    }

    ControlSection {
        id: controlPanel

        anchors {
            top: parent.top; topMargin: 25
            bottom: parent.bottom; bottomMargin: 25
            left: gasStationMap.right; leftMargin: 50
            right: parent.right; rightMargin: 25
        }

        backgroundRadius: mainPage.radius
    }
}
