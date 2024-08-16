import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15

import ApplicationSettings 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: controlSection

    property color textColor: Theme.text
    property color backgroundColor: Theme.mid
    property real backgroundRadius: 25

    property int selectedPanel: 0

    Rectangle {
        id: background

        anchors.fill: parent
        
        radius: controlSection.backgroundRadius
        color: controlSection.backgroundColor
    }
    Item {
        id: header

        height: Utils.perc(controlSection.height, 15)

        anchors {
            top: parent.top; margins: 5
            left: parent.left; right: parent.right
        }

        RowLayout {
            id: userControl

            width: parent.width
            height: Utils.perc(parent.height, 60)

            anchors.top: parent.top

            Controls.Label {
                Layout.preferredWidth: Utils.perc(parent.width, 75)
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft   
                horizontalAlignment: Text.AlignLeft  
                text: "Welcome [user]!"
                leftPadding: 3
            }
            Controls.Button {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignRight  
                iconCode: Utils.getIcon(0xE4C2)
                radius: controlSection.backgroundRadius
            }
        }
        ButtonGroup {
            id: headerButtonGroup
        
            buttons: headerButtons.children
            exclusive: true

            onClicked: {
                switch(button.text) {
                    case "Gas Stations": body.model = gasStationModel; return
                    case "Statistics": body.model = statisticsModel; return
                    case "User Panel": body.model = undefined; return
                    default: return
                }
            }
        }
        RowLayout {
            id: headerButtons

            width: parent.width
            height: Utils.perc(parent.height, 30)
 
            anchors { top: userControl.bottom; topMargin: 5 }
            
            Controls.Button {
                Layout.fillHeight: true
                Layout.fillWidth: true
                checkable: true
                checked: true
                text: "Gas Stations"

                Component.onCompleted: body.model = gasStationModel
            }
            Controls.Button {
                Layout.fillHeight: true
                Layout.fillWidth: true
                checkable: true
                checked: false
                text: "Statistics"
            }
            Controls.Button {
                Layout.fillHeight: true
                Layout.fillWidth: true
                checkable: true
                checked: false
                text: "User Panel"
            }
        }

        Rectangle {
            width: parent.width-2
            height: 1
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            color: Theme.text
        }
    }

    ScrollView {
        id: body

        property alias model: bodyView.model

        anchors {
            fill: parent
            topMargin: header.height+(body.anchors.margins*2); margins: 5
        }

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        clip: true

        ListView {
            id: bodyView
        
            spacing: 5
            onModelChanged: {
                bodyView.positionViewAtBeginning()
                bodyView.forceLayout()
                bodyView.forceActiveFocus()
            }
        }
    }

    ObjectModel {
        id: gasStationModel

        Controls.TextField {
            id: searchbar

            width: body.width
            height: Utils.perc(body.height, 7.5)

            placeholder: "Search by Name"
        }
        // Controls.Label { text: "Filter by Name" }
    }

    ObjectModel {
        id: statisticsModel

        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "green" }
        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "yellow" }
        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "orange" }
        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "gray" }
    }
}