import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtGraphicalEffects 1.12

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: card

    property string name: ""
    property var fuelList

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
        radius: card.radius
        color: card.backgroundColor
    }
    Controls.Label {
        id: title

        width: card.width-10
        height: Utils.perc(parent.height, 20)

        anchors {
            top: parent.top; topMargin: 5
            left: parent.left; leftMargin: 5
        }

        clip: true
        text: card.name === "" ? "Fuel List" : card.name + " - Fuel List"
        font {
            bold: true
            pointSize: 15
        }
        horizontalAlignment: Text.AlignLeft
    }

    ListView {
        id: fuelView

        anchors {
            fill: parent; topMargin: title.height+5
            margins: 5
        }
        spacing: 5

        clip: true
        model: card.fuelList

        delegate: Item {
            id: __fuel
            
            width: fuelView.width
            height: Utils.perc(fuelView.height, 25)-fuelView.spacing

            Rectangle {
                id: fuelBackground

                anchors.fill: parent
                color: Theme.light
                
                radius: 5
            }
            RowLayout {
                id: fuelRow

                anchors.fill: parent
                spacing: 5

                Image {
                    id: logo

                    Layout.preferredWidth: Utils.perc(fuelRow.height, 90)-fuelRow.spacing
                    Layout.preferredHeight: Utils.perc(fuelRow.height, 90)

                    source: "./resources/" + modelData[1].toLowerCase() + ".svg" //"data:image/svg+xml;utf8," + modelData.
                }
                Controls.Label {
                    id: name
                    
                    Layout.preferredWidth: Utils.perc(fuelRow.width-logo.width, 45)-fuelRow.spacing
                    Layout.preferredHeight: Utils.perc(fuelRow.height, 90)

                    text: modelData[1] + (modelData[3] ? " (Self)" : " (Servito)")
                    horizontalAlignment: Text.AlignLeft
                }
                Controls.Label {
                    id: price
                    
                    Layout.preferredWidth: Utils.perc(fuelRow.width-logo.width, 35)-fuelRow.spacing
                    Layout.preferredHeight: Utils.perc(fuelRow.height, 90)

                    text: modelData[2] + "€/L"
                    horizontalAlignment: Text.AlignLeft
                }
                Controls.Button {
                    id: buyButton
                    
                    Layout.preferredWidth: Utils.perc(fuelRow.width-logo.width, 20)-(fuelRow.spacing*4)
                    Layout.preferredHeight: Utils.perc(fuelRow.height, 80)

                    text: "Buy"
                }
            }
        }
    }
}