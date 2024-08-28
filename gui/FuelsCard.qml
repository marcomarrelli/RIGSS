import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Transactions 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: card

    property string name: ""
    property var fuelList

    property string userID: ""
    property int gasStationID

    property color textColor: Theme.text
    property color backgroundColor: Theme.mid
    property real radius: 12.5

    property alias ratingsVisible: reviewsPanel.visible

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

        width: (card.width*0.8)-5
        height: Utils.perc(parent.height, 20)

        anchors {
            top: parent.top; topMargin: 5
            left: parent.left; leftMargin: 5
        }

        clip: true
        text: card.name === "" ? "Fuel List" : card.name + "\nFuel List"
        font {
            bold: true
            pointSize: 15
        }
        horizontalAlignment: Text.AlignLeft
    }
    Controls.Button {
        id: reviews

        width: (card.width*0.2)-5
        height: Utils.perc(parent.height, 10)

        anchors {
            verticalCenter: title.verticalCenter
            right: parent.right; rightMargin: 5
        }

        text: "See Reviews"
        onClicked: {
            reviewsPanel.name = card.name ?? ""
            reviewsPanel.userID = card.userID ?? ""
            reviewsPanel.gasStationID = card.gasStationID ?? -1

            reviewsPanel.visible = true
        }
    }
    ListView {
        id: fuelView

        anchors {
            top: title.bottom; bottom: shopRow.top; bottomMargin: 10
            left: card.left; right: card.right; margins: 5
        }
        spacing: 5

        opacity: enabled ? 1 : 0.5
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

                    text: modelData[1] + (modelData[3] ? " (Self)" : " (Served)")
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

                    enabled: card.userID !== ""
                    text: "Buy"
                    opacity: card.userID !== "" ? 1 : 0.5
                    backgroundColor: Qt.lighter(Theme.light, 1.25)

                    onClicked: shopRow.open(String(modelData[1]), modelData[3], modelData[2])
                }
            }
        }
    }

    RowLayout {
        id: shopRow

        property string gasName: ""
        property bool selfService: false
        property real pricePerLiter: 0.0
        
        readonly property real totalPrice: (parseFloat(liters.text)*shopRow.pricePerLiter).toFixed(2)
        
        function open(name = "", isSelf = false, price = 0.0) {
            if(name === "" || price === 0) return

            shopRow.gasName = name
            shopRow.selfService = isSelf
            shopRow.pricePerLiter = price

            fuelView.enabled = false
            shopRow.visible = true
        }
        function close() {
            shopRow.gasName = ""
            shopRow.pricePerLiter = 0
            
            liters.text = ""
            paymentMethod.currentIndex = -1

            shopRow.visible = false
            fuelView.enabled = true
        }
        
        visible: false

        height: Utils.perc(card.height, 15)
        anchors {
            left: card.left; leftMargin: 5
            right: card.right; rightMargin: 5
            bottom: card.bottom; bottomMargin: 10
        }
        spacing: 5

        Controls.Label {
            Layout.preferredWidth: Utils.perc(shopRow.width, 9)-shopRow.spacing
            Layout.fillHeight: true

            text: "Buying"
            horizontalAlignment: Text.AlignLeft
        }
        Controls.TextField {
            id: liters

            Layout.preferredWidth: Utils.perc(shopRow.width, 12.5)-shopRow.spacing
            Layout.fillHeight: true

            text: ""
            validator: RegularExpressionValidator {
                regularExpression: /^$|([0-9]*)?[.]?[0-9]+/
            }
        }
        Controls.Label {
            Layout.preferredWidth: Utils.perc(shopRow.width, 13.5)-shopRow.spacing
            Layout.fillHeight: true

            text: "L of " + shopRow.gasName + "\n" + (shopRow.selfService ? "Self" : "Served")
            horizontalAlignment: Text.AlignLeft
        }
        Controls.Label {
            Layout.preferredWidth: Utils.perc(shopRow.width, 2.5)-shopRow.spacing
            Layout.fillHeight: true

            text: "|"
        }
        Controls.ComboBox {
            id: paymentMethod

            Layout.preferredWidth: Utils.perc(shopRow.width, 20)-shopRow.spacing
            Layout.fillHeight: true

            currentIndex: -1
            model: ["Cash", "Debit Card", "Credit Card"]
        }
        Controls.Label {
            Layout.preferredWidth: Utils.perc(shopRow.width, 2.5)-shopRow.spacing
            Layout.fillHeight: true

            text: "|"
        }
        Controls.Label {
            Layout.preferredWidth: Utils.perc(shopRow.width, 20)-shopRow.spacing
            Layout.fillHeight: true

            text: "Total: " + (isNaN(shopRow.totalPrice) ? "0" : String(shopRow.totalPrice)) + " €"
            horizontalAlignment: Text.AlignLeft
        }
        Controls.Label {
            Layout.preferredWidth: Utils.perc(shopRow.width, 2.5)-shopRow.spacing
            Layout.fillHeight: true

            text: "|"
        }
        Controls.Button {
            Layout.preferredWidth: Utils.perc(shopRow.width, 7.5)-shopRow.spacing
            Layout.fillHeight: true

            iconCode: Utils.getIcon(0xE4F6)
            onClicked: shopRow.close()
        }
        Controls.Button {
            id: buyButton

            Layout.preferredWidth: Utils.perc(shopRow.width, 7.5)-shopRow.spacing
            Layout.fillHeight: true

            enabled: ((parseFloat(liters.text) > 0) && (liters.text !== "") && (paymentMethod.currentIndex >= 0))
            iconCode: Utils.getIcon(0xE182)

            onClicked: {
                if(!Utils.exists(card.gasStationID)) return
                if(!Utils.exists(card.userID) || card.userID === "") return

                if(transactionManager.executeTransaction(
                    card.gasStationID, card.userID, paymentMethod.currentIndex, shopRow.gasName, shopRow.selfService, parseFloat(liters.text).toFixed(2), shopRow.totalPrice
                )) shopRow.close()
            }
        }
    }

    ReviewsPanel {
        id: reviewsPanel

        anchors.fill: parent
        visible: false

        name: card.name
        userID: card.userID
        gasStationID: card.gasStationID
    }

    Transactions { id: transactionManager }
}