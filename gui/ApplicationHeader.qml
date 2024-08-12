import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import ApplicationSettings 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

ToolBar {
    id: toolbar

    required property ApplicationWindow parentWindow

    Rectangle {
        anchors.fill: parent
        color: Theme.mid
    }
    RowLayout {
        anchors {
            fill: parent
            margins: 5
        }
        spacing: 5

        Controls.Button { 
            Layout.preferredWidth: Utils.perc(parent.width, 10)-parent.spacing
            Layout.fillHeight: true

            backgroundColor: Theme.light
            borderColor: "transparent"

            iconCode: Utils.getIcon(Theme.isDarkMode() ? 0xE474 : 0xE330)
            onClicked: Theme.switchMode()
        }
        Controls.Button { 
            Layout.preferredWidth: Utils.perc(parent.width, 10)-parent.spacing
            Layout.fillHeight: true

            backgroundColor: Theme.light
            borderColor: "transparent"

            iconCode: Utils.getIcon(parentWindow.visibility === Window.FullScreen ? 0xE1CE : 0xE1D0)
            onClicked: parentWindow.visibility === Window.FullScreen ? parentWindow.showNormal() : parentWindow.showFullScreen()
        }
        Controls.Label {
            Layout.preferredWidth: Utils.perc(parent.width, 60)-parent.spacing
            Layout.fillHeight: true

            text: "RIGSS"
        }
        Controls.Button { 
            Layout.preferredWidth: Utils.perc(parent.width, 20)-parent.spacing
            Layout.fillHeight: true

            backgroundColor: Theme.light
            borderColor: "transparent"

            iconCode: Utils.getIcon(0xE42A)
            onClicked: Qt.callLater(Qt.quit)
        }
    }
}