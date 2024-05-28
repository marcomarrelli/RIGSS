import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import QtGraphicalEffects 1.12

import ApplicationSettings 1.0

import "../logic/utils.js" as Utils

Item {
    id: controlSection

    property color textColor: Theme.text
    property color backgroundColor: Theme.mid

    property real backgroundRadius: 25

    Rectangle {
        id: background

        anchors.fill: parent
        
        radius: controlSection.backgroundRadius
        color: controlSection.backgroundColor
    }
    ColumnLayout {
        id: body

        anchors.fill: parent
        spacing: 5
    }
}