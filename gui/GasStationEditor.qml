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

    required property string usernameGestore

    property var gasStation
    property var gasStationManager

    property color textColor: Theme.text
    property color backgroundColor: Theme.mid
    property real radius: 12.5

    signal getMapCenter()
    signal refresh()

    function setPosition(position) {
        if(!position) return

        latitudineField.text = String(position.latitude)
        longitudineField.text = String(position.longitude)
    }

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

        text: Utils.exists(gasStation) ? "Edit Gas Station" : "Add Gas Station"
        leftPadding: 5; font.bold: true
        horizontalAlignment: Text.AlignLeft
    }
    ScrollView {
        id: body

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

            model: formLayout
        }
    }

    ObjectModel {
        id: formLayout

        Controls.TextField {
            id: nomeField
            
            width: body.width
            height: Utils.perc(body.height, 10)
            
            text: Utils.exists(gasStation) ? gasStation.nome ?? "" : ""
            placeholder: "Nome"
        }

        Controls.TextField {
            id: gestoreField
            
            width: body.width
            height: Utils.perc(body.height, 10)

            text: editor.usernameGestore
            enabled: false
        }

        RowLayout {
            width: body.width
            height: Utils.perc(body.height, 10)

            spacing: 5

            Controls.ComboBox {
                id: bandieraField

                currentIndex: Utils.exists(gasStation) ? model.indexOf(gasStation.bandiera) : -1
                model: ["Q8", "Esso", "Agip Eni", "Pompe Bianche", "Api-Ip", "Tamoil"]

                Layout.preferredWidth: Utils.perc(parent.width, 50)-5
                Layout.fillHeight: true
            }

            Controls.ComboBox {
                id: tipologiaField

                currentIndex: Utils.exists(gasStation) ? model.indexOf(gasStation.tipologia) : -1
                model: ["Stradale", "Autostradale"]
                
                Layout.preferredWidth: Utils.perc(parent.width, 50)-5
                Layout.fillHeight: true
            }           
        }

        Controls.TextField {
            id: viaField
            
            width: body.width
            height: Utils.perc(body.height, 10)

            text: Utils.exists(gasStation) ? gasStation.via ?? "" : ""
            placeholder: "Via"
        }

        RowLayout {
            width: body.width
            height: Utils.perc(body.height, 10)

            spacing: 5

            Controls.TextField {
                id: comuneField

                Layout.preferredWidth: Utils.perc(parent.width, 50)-5
                Layout.fillHeight: true

                text: Utils.exists(gasStation) ? gasStation.comune ?? "" : ""
                placeholder: "Comune"
            }

            Controls.TextField {
                id: provinciaField

                Layout.preferredWidth: Utils.perc(parent.width, 30)-5
                Layout.fillHeight: true

                text: Utils.exists(gasStation) ? gasStation.provincia ?? "" : ""
                placeholder: "Provincia"
                validator: RegularExpressionValidator { regularExpression: /[A-Z]{2}/ }
            }

            Controls.TextField {
                id: capField
                
                Layout.preferredWidth: Utils.perc(parent.width, 20)-5
                Layout.fillHeight: true

                text: Utils.exists(gasStation) ? gasStation.cap ?? "" : ""
                placeholder: "CAP"
                validator: RegularExpressionValidator { regularExpression: /[0-9]{5}/ }
            }
        }

        RowLayout {
            width: body.width
            height: Utils.perc(body.height, 10)

            spacing: 5

            Controls.TextField {
                id: latitudineField

                Layout.preferredWidth: Utils.perc(parent.width, 45)-5
                Layout.fillHeight: true

                text: Utils.exists(gasStation) ? gasStation.latitudine ?? "" : ""
                placeholder: "Latitudine"
                validator: RegularExpressionValidator { regularExpression: /^$|([0-9]*)?[.]?[0-9]+/  }
            }

            Controls.TextField {
                id: longitudineField

                Layout.preferredWidth: Utils.perc(parent.width, 45)-5
                Layout.fillHeight: true

                text: Utils.exists(gasStation) ? gasStation.longitudine ?? "" : ""
                placeholder: "Longitudine"
                validator: RegularExpressionValidator { regularExpression: /^$|([0-9]*)?[.]?[0-9]+/  }
            }

            Controls.Button {
                id: positionGetter

                Layout.preferredWidth: Utils.perc(parent.width, 10)-5
                Layout.fillHeight: true

                iconCode: Utils.getIcon(0xE1D6)
                onClicked: editor.getMapCenter()
            }
        }

        Item {
            width: body.width
            height: Utils.perc(body.height, 5)
        }

        RowLayout {
            id: actionRow

            width: body.width
            height: Utils.perc(body.height, 10)

            spacing: 5

            Controls.Button {
                id: clearButton

                Layout.preferredWidth: Utils.perc(parent.width, 50)-5
                Layout.fillHeight: true
                
                text: "Clear"
                onClicked: {
                    errorLabel.text = ""

                    nomeField.text = ""
                    viaField.text = ""
                    comuneField.text = ""
                    provinciaField.text = ""
                    capField.text = ""
                    latitudineField.text = ""
                    longitudineField.text = ""
                    bandieraField.currentIndex = -1
                    tipologiaField.currentIndex = -1
                }
            }

            Controls.Button {
                id: addButton

                Layout.preferredWidth: Utils.perc(parent.width, 50)-5
                Layout.fillHeight: true

                text: Utils.exists(gasStation) ? "Edit" : "Add"
                onClicked: {
                    errorLabel.text = ""

                    if(nomeField.text === "") {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) Name!"
                        return
                    }
                    else if(viaField.text === "") {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) Street!"
                        return
                    }
                    else if(comuneField.text === "") {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) City!"
                        return
                    }
                    else if(provinciaField.text === "") {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) Province!"
                        return
                    }
                    else if(capField.text === "") {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) CAP!"
                        return
                    }
                    else if(latitudineField.text === "") {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) Latitude!"
                        return
                    }
                    else if(longitudineField.text === "") {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) Longitude!"
                        return
                    }
                    else if(bandieraField.currentIndex === -1) {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) Gas Station Brand!"
                        return
                    }
                    else if(tipologiaField.currentIndex === -1) {
                        errorLabel.text = "Must Set a Valid (and Non-Blank) Gas Station Type!"
                        return
                    }

                    var success
                    if(Utils.exists(gasStation)) {
                        success = gasStationManager.updateGasStation(
                            gasStation.idImpianto,
                            String(gestoreField.text),
                            bandieraField.currentText,
                            tipologiaField.currentText,
                            String(nomeField.text),
                            String(viaField.text),
                            capField.text,
                            String(comuneField.text),
                            provinciaField.text,
                            parseFloat(latitudineField.text),
                            parseFloat(longitudineField.text)
                        )

                        if(success) {
                            errorLabel.text = "Gas Station '" + nomeField.text + "' Updated Successfully!"
                            actionRow.enabled = false
                        }
                        else errorLabel.text = "Couldn't Edit Gas Station!"
                    }
                    else {
                        success = gasStationManager.insertGasStation(
                            String(gestoreField.text),
                            bandieraField.currentText,
                            tipologiaField.currentText,
                            String(nomeField.text),
                            String(viaField.text),
                            capField.text,
                            String(comuneField.text),
                            provinciaField.text,
                            parseFloat(latitudineField.text),
                            parseFloat(longitudineField.text)
                        )

                        if(success) {
                            errorLabel.text = "Gas Station '" + nomeField.text + "' Added Successfully!"
                            actionRow.enabled = false
                        }
                        else errorLabel.text = "Couldn't Add Gas Station!"
                    }
                }
            }
        }

        Controls.Label {
            id: errorLabel

            width: body.width
            height: Utils.perc(body.height, 7.5)

            color: Theme.highlight
            wrapMode: Text.WordWrap
            text: ""
        }
    }

    onVisibleChanged: {
        actionRow.enabled = true
        errorLabel.text = ""
    }
}