import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import QtLocation 5.15
import QtPositioning 5.15

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: editor

    property var gasStation
    property var gasStationManager

    property color textColor: Theme.text
    property color backgroundColor: Theme.mid
    property real radius: 12.5

    Rectangle {
        id: background

        anchors.fill: parent

        border {
            width: 1
            color: Theme.border
        }
        radius: editor.radius
        color: editor.backgroundColor
    }

    Controls.Label {
        id: header

        width: editor.width
        height: Utils.perc(editor.height, 10)

        text: "Edit Fuels"
        leftPadding: 5; font.bold: true
        horizontalAlignment: Text.AlignLeft
    }
    ScrollView {
        id: body

        anchors {
            top: header.bottom; topMargin: 10
            bottom: actionRow.top; bottomMargin: 5
            left: editor.left; leftMargin: 5
            right: editor.right; rightMargin: 5
        }

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        clip: true

        ListView {
            id: bodyView

            property var addedFuelsList: []

            function getAddedFuels() {
                if(!gasStation || !gasStationManager) return false
                
                var fuels = gasStationManager.getFuels(gasStation.idImpianto)
                if(fuels.length === 0) return false

                fuels.forEach(e => {
                    bodyView.addedFuelsList.push({
                        "name": e[1] + " (" + (e[3] ? "Self" : "Served") + ")",
                        "price": e[2]
                    })
                })
                return true
            }

            function getPrice(name = "") {
                if(name === "") return 0

                if(!bodyView.getAddedFuels()) return undefined
                var temp = bodyView.addedFuelsList.find(t => t.name === name)
                return temp ? temp.price : undefined
            }

            function fetchAll(command = "") {
                for(var i=0; i<bodyView.count; i++) {
                    if(command === "clear") bodyView.itemAtIndex(i).clear()
                    else if(command === "save") bodyView.itemAtIndex(i).execute()
                }
            }

            spacing: 5
            reuseItems: true

            model: ["Benzina (Self)", "Benzina (Served)", "Gasolio (Self)", "Gasolio (Served)", "Metano (Self)", "Metano (Served)", "GPL (Served)"]
            delegate: RowLayout {
                id: fuelRow

                function execute() {
                    if(modelData === "") return

                    bodyView.getAddedFuels()

                    var tempNome = modelData.split(" ")[0]
                    var tempSelf = modelData.split(" ")[1].slice(1, -1) === "Self"
                    var tempPrice = bodyView.getPrice(modelData)

                    var check = false

                    if(parseFloat(fuelPrice.text) === 0 || fuelPrice.text === "") {
                        check = editor.gasStationManager.updateFuel(editor.gasStation.idImpianto, tempNome, 0, tempSelf)
                        errorLabel.text = check ? "Fuel Deleted!" : "Error! Couldn't Delete Fuel."
                    }
                    else if(!tempPrice) {
                        check = editor.gasStationManager.insertFuel(editor.gasStation.idImpianto, tempNome, parseFloat(fuelPrice.text).toFixed(3), tempSelf)
                        errorLabel.text = check ? "Fuel Inserted!" : "Error! Couldn't Add Fuel."
                    }
                    else if(tempPrice && (tempPrice.toFixed(3) !== parseFloat(fuelPrice.text).toFixed(3))) {
                        check = editor.gasStationManager.updateFuel(editor.gasStation.idImpianto, tempNome, parseFloat(fuelPrice.text).toFixed(3), tempSelf)
                        errorLabel.text = check ? "Fuel Updated!" : "Error! Couldn't Update Fuel."
                    }
                }

                function clear() {
                    fuelPrice.text = ""
                }

                width: body.width
                height: Utils.perc(body.height, 10)

                Controls.TextField {
                    id: fuelName

                    Layout.preferredWidth: Utils.perc(parent.width, 40)-parent.spacing
                    Layout.fillHeight: true

                    text: modelData
                    readOnly: true
                }
                Controls.TextField {
                    id: fuelPrice

                    Layout.preferredWidth: Utils.perc(parent.width, 30)-parent.spacing
                    Layout.fillHeight: true
                    
                    text: bodyView.getPrice(modelData) ?? ""
                    validator: RegularExpressionValidator {
                        regularExpression: /^$|([0-9]*)?[.]?[0-9]+/
                    }
                }
                Controls.Label {
                    Layout.preferredWidth: Utils.perc(parent.width, 10)-parent.spacing
                    Layout.fillHeight: true

                    text: "€/L"
                    horizontalAlignment: Text.AlignLeft
                }
                Controls.Button {
                    Layout.preferredWidth: Utils.perc(parent.width, 10)-parent.spacing
                    Layout.fillHeight: true

                    iconCode: Utils.getIcon(0xE182)
                    onClicked: fuelRow.execute()
                }
                Controls.Button {
                    Layout.preferredWidth: Utils.perc(parent.width, 10)-parent.spacing
                    Layout.fillHeight: true

                    enabled: fuelPrice.text !== "" && parseFloat(fuelPrice.text) !== 0
                    iconCode: Utils.getIcon(0xE4A6)
                    onClicked: {
                        if(!enabled) return
                        fuelPrice.text = ""
                        fuelRow.execute()
                    }
                }
            }

            Component.onCompleted: bodyView.getAddedFuels()
        }
    }

    RowLayout {
        id: actionRow
        
        height: Utils.perc(editor.height, 7.5)
        anchors {
            left: editor.left; leftMargin: 5
            right: editor.right; rightMargin: 5
            bottom: errorLabel.top; bottomMargin: Utils.perc(editor.height, 1)
        }
        spacing: 5
        
        Controls.Button {
            id: clearButton
        
            Layout.preferredWidth: Utils.perc(parent.width, 50)-5
            Layout.fillHeight: true
            
            text: "Clear All"
            onClicked: {
                errorLabel.text = ""
                bodyView.fetchAll("clear")
            }
        }
        Controls.Button {
            id: addButton
            Layout.preferredWidth: Utils.perc(parent.width, 50)-5
            Layout.fillHeight: true
            text: "Save"
            onClicked: {
                bodyView.fetchAll("save")
                errorLabel.text = "Everything Saved!"
            }
        }
    }
    Controls.Label {
        id: errorLabel

        height: Utils.perc(editor.height, 5)
        anchors {
            left: editor.left; leftMargin: 5
            right: editor.right; rightMargin: 5
            bottom: editor.bottom; bottomMargin: Utils.perc(editor.height, 1)
        }
        color: Theme.highlight
        wrapMode: Text.WordWrap
        text: ""
    }

    onVisibleChanged: {
        actionRow.enabled = true
        errorLabel.text = ""
    }
}