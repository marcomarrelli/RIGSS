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

    property var gasStations
    property string username: ""

    signal gasStationSelected(gasStation: var)
    signal openUserPage()

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
                text: controlSection.username === "" ? "Welcome!" : "Welcome " + controlSection.username + "!"
                font.bold: true
                leftPadding: 3
            }
            Controls.Button {
                Layout.preferredHeight: Utils.perc(parent.height, 75)
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                iconCode: Utils.getIcon(0xE4C2)
                radius: controlSection.backgroundRadius
                enabled: controlSection.username !== ""
                opacity: enabled ? 1 : 0.25

                onClicked: controlSection.openUserPage()
            }
        }
        ButtonGroup {
            id: headerButtonGroup
        
            buttons: headerButtons.children
            exclusive: true

            onClicked: {
                switch(button.text) {
                    case "Gas Stations": body.model = gasStationModel; return
                    case "Advanced": body.model = advancedSearchModel; return
                    case "Statistics": body.model = statisticsModel; return
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
                text: "Advanced"
            }
            Controls.Button {
                Layout.fillHeight: true
                Layout.fillWidth: true
                checkable: true
                checked: false
                text: "Statistics"
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
            reuseItems: true
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

            placeholder: "Search by Name or Place"

            onTextChanged: controlSection.gasStations.filter.name = text
        }
        ListView {        
            id: gasStationView

            width: body.width
            height: Utils.perc(body.height, 87.5)
            
            spacing: 5
            reuseItems: true
            clip: true

            model: controlSection.gasStations.model
            delegate: GasStationCard {
                width: gasStationView.width
                height: Utils.perc(gasStationView.height, 22.5)

                gasStation: model
                gasStationData: controlSection.gasStations.model
                onClicked: controlSection.gasStationSelected(this.gasStation)
            }

            onModelChanged: {
                gasStationView.positionViewAtBeginning()
                gasStationView.forceLayout()
                gasStationView.forceActiveFocus()
            }
        }
    }

    ObjectModel {
        id: advancedSearchModel

        RowLayout {
            width: body.width
            height: Utils.perc(body.height, 7.5)

            spacing: 5

            Controls.Label {
                Layout.preferredWidth: Utils.perc(parent.width, 40)-parent.spacing
                Layout.fillHeight: true

                text: "Set Max Price: "
                horizontalAlignment: Text.AlignLeft
            }
            Controls.TextField {
                Layout.preferredWidth: Utils.perc(parent.width, 55)-parent.spacing
                Layout.fillHeight: true
                
                text: ""
                validator: RegularExpressionValidator {
                    regularExpression: /^$|([0-9]*)?[.]?[0-9]+/ // /([0-9]*)?[.]?[0-9]+/
                }

                onEditingFinished: {
                    if(text === "") text = "0"
                    if(acceptableInput) controlSection.gasStations.filter.maxPrice = parseFloat(text)
                }
            }
            Controls.Label {
                Layout.preferredWidth: Utils.perc(parent.width, 5)-parent.spacing
                Layout.fillHeight: true

                text: "€"
                horizontalAlignment: Text.AlignLeft
            }
        }
        Rectangle {
            width: body.width; height: 1
            color: Theme.light; opacity: 0.75
        }
        Controls.Label {
            width: body.width
            height: Utils.perc(body.height, 7.5)

            text: "Choose Available Fuels:"
            horizontalAlignment: Text.AlignLeft
        }
        RowLayout {
            id: fuelButtonRow

            width: body.width
            height: Utils.perc(body.height, 7.5)

            spacing: 5

            Repeater {
                model: ["Benzina", "Gasolio", "Metano", "GPL"]

                delegate: Controls.Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: modelData
                    checkable: true

                    onCheckedChanged: {
                        if(text === "") return

                        if(checked) controlSection.gasStations.filter.addAvailableFuel(text)
                        else controlSection.gasStations.filter.removeAvailableFuel(text)
                    }

                    Component.onCompleted: checked = true
                }
            }
        }
        Rectangle {
            width: body.width; height: 1
            color: Theme.light; opacity: 0.75
        }
        Controls.Label {
            width: body.width
            height: Utils.perc(body.height, 7.5)

            text: "Select Service Mode:"
            horizontalAlignment: Text.AlignLeft
        }
        RowLayout {
            id: selfButtonRow

            width: body.width
            height: Utils.perc(body.height, 7.5)

            spacing: 5

            function getServiceStatus(self = selfButton.checked, served = servedButton.checked) {
                if(self === undefined || served === undefined) return 2
                
                if((self && served) || (!self && !served)) return 2
                else return self ? 1 : 0
            }

            Controls.Button {
                id: selfButton

                Layout.fillWidth: true
                Layout.fillHeight: true

                text: "Self"
                checkable: true
                checked: true
                
                onCheckedChanged: controlSection.gasStations.filter.service = selfButtonRow.getServiceStatus()
            }
            Controls.Button {
                id: servedButton

                Layout.fillWidth: true
                Layout.fillHeight: true

                text: "Served"
                checkable: true
                checked: true
        
                onCheckedChanged: controlSection.gasStations.filter.service = selfButtonRow.getServiceStatus()
            }
        }
        Rectangle {
            width: body.width; height: 1
            color: Theme.light; opacity: 0.75
        }
        Controls.Label {
            width: body.width
            height: Utils.perc(body.height, 7.5)

            text: "Sort Gas Stations List:"
            horizontalAlignment: Text.AlignLeft
        }
        RowLayout {
            id: alphabeticOrderRow

            width: body.width
            height: Utils.perc(body.height, 7.5)

            spacing: 5

            Controls.Button {
                Layout.fillWidth: true; Layout.fillHeight: true
                text: "Ascendent"
                onClicked: controlSection.gasStations.sortAscendent()
            }
            Controls.Button {
                Layout.fillWidth: true; Layout.fillHeight: true
                text: "Descendent"
                onClicked: controlSection.gasStations.sortDescendent()
            }
            Controls.Button {
                Layout.fillWidth: true; Layout.fillHeight: true
                text: "Default"
                onClicked: controlSection.gasStations.filter.order = ""
            }
        }
    }

    ObjectModel {
        id: statisticsModel

        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "green" }
        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "yellow" }
        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "orange" }
        Rectangle { width: body.width; height: Utils.perc(body.height, 30); color: "gray" }
    }
}