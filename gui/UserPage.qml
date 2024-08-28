import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15

import ApplicationSettings 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: userPage

    required property string username
    property var gasStations

    property color textColor: Theme.text
    property color backgroundColor: Theme.mid
    property real backgroundRadius: 25

    property var selectedGasStation: undefined

    signal add()
    signal addFuels(gasStation: var)
    signal edit(gasStation: var)
    signal remove(gasStation: var)

    signal close()

    function refreshModel() {
        userView.model = userPage.gasStations.getOwnGasStations(userPage.username, true)
        userView.positionViewAtBeginning()
        userView.forceLayout()
        userView.forceActiveFocus()
    }

    Rectangle {
        id: background

        anchors.fill: parent
        
        radius: userPage.backgroundRadius
        color: userPage.backgroundColor
    }

    Item {
        id: header

        height: Utils.perc(userPage.height, 15)

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
                text: userPage.username + "'s User Page"
                font.bold: true
                leftPadding: 3
            }
            Controls.Button {
                Layout.preferredHeight: Utils.perc(parent.height, 75)
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                iconCode: Utils.getIcon(0xE4F6)
                radius: userPage.backgroundRadius

                onClicked: userPage.close()
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
                text: "Add"
                onClicked: userPage.add()
            }
            Controls.Button {
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "Fuels.."
                enabled: Utils.exists(userPage.selectedGasStation)
                onClicked: userPage.addFuels(userPage.selectedGasStation)
            }
            Controls.Button {
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "Edit"
                enabled: Utils.exists(userPage.selectedGasStation)
                onClicked: userPage.edit(userPage.selectedGasStation)
            }
            Controls.Button {
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: "Remove"
                enabled: Utils.exists(userPage.selectedGasStation)
                onClicked: userPage.remove(userPage.selectedGasStation)
            }
        }
        Rectangle {
            width: parent.width-2
            height: 1
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            color: Theme.text
        }
    }
    // Controls.TextField {
    //     id: searchbar
    //     
    //     height: Utils.perc(parent.height, 7)-5
    //     anchors {
    //         left: parent.left; right: parent.right
    //         top: header.bottom; margins: 5
    //     }
    //     
    //     placeholder: "Search by Name or Place"
    // }
    ScrollView {
        id: body

        property alias model: userView.model

        anchors {
            top: header.bottom; topMargin: 5 //top: searchbar.bottom; topMargin: 5
            bottom: parent.bottom; bottomMargin: 10
            left: parent.left; leftMargin: 5
            right: parent.right; rightMargin: 5
        }

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        clip: true

        ListView {        
            id: userView

            width: body.width
            height: Utils.perc(body.height, 87.5)
            
            spacing: 5
            reuseItems: true
            clip: true

            model: userPage.gasStations.getOwnGasStations(userPage.username, true)
            delegate: GasStationCard {
                width: userView.width
                height: Utils.perc(userView.height, 22.5)

                selected: model === userPage.selectedGasStation
                gasStation: model
                gasStationData: userPage.gasStations.model

                onClicked: {
                    if(selected) userPage.selectedGasStation = undefined
                    else userPage.selectedGasStation = model
                }
            }
        }
    }
}