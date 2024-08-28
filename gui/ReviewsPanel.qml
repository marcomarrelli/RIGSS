import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Reviews 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: reviewPanel

    property string name: ""
    
    property string userID: ""
    property int gasStationID: -1

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
        radius: reviewPanel.radius
        color: reviewPanel.backgroundColor
    }
    Controls.Label {
        id: title

        width: (reviewPanel.width*0.5)-5
        height: Utils.perc(parent.height, 20)

        anchors {
            top: parent.top; topMargin: 5
            left: parent.left; leftMargin: 5
        }

        clip: true
        text: reviewPanel.name === "" ? "Reviews" : reviewPanel.name + "\nReviews"
        font {
            bold: true
            pointSize: 15
        }
        horizontalAlignment: Text.AlignLeft
    }
    Controls.Label {
        id: reviews

        function setAverage() {
            reviews.text = reviewPanel.gasStationID !== -1 ? Utils.getIcon(0xE46A).repeat(reviewsManager.getAverageRating(reviewPanel.gasStationID ?? 0)) : ""
        }

        height: Utils.perc(parent.height, 10)
        anchors {
            verticalCenter: title.verticalCenter
            left: title.right; leftMargin: 10
            right: addRating.left; rightMargin: 10
        }

        fontSize: 20
        fontFamily: "Phosphor"
        text: reviewPanel.gasStationID !== -1 ? Utils.getIcon(0xE46A).repeat(reviewsManager.getAverageRating(reviewPanel.gasStationID ?? 0)) : ""
        textColor: Theme.highlight
    }
    Controls.Button {
        id: addRating

        width: (reviewPanel.width*0.1)-5
        height: Utils.perc(parent.height, 10)

        anchors {
            verticalCenter: title.verticalCenter
            right: close.left; rightMargin: 5
        }

        checkable: true
        checked: false

        enabled: ((reviewPanel.gasStationID !== -1) && (reviewPanel.userID !== "") && (reviewsManager.canAddReview(reviewPanel.gasStationID, reviewPanel.userID)))
        iconCode: Utils.getIcon(0xE236)
        onCheckedChanged: {
            if(!checked) {
                ratingView.enabled = true
                starBox.currentIndex = 0
                reviewText.text = ""
            }
            else ratingView.enabled = false

            controlRow.visible = checked
        }
    }
    Controls.Button {
        id: close

        width: (reviewPanel.width*0.1)-5
        height: Utils.perc(parent.height, 10)

        anchors {
            verticalCenter: title.verticalCenter
            right: parent.right; rightMargin: 5
        }

        iconCode: Utils.getIcon(0xE4F6)
        onClicked: reviewPanel.visible = false
    }
    ListView {
        id: ratingView

        function refreshRatings() {
            ratingView.model = reviewsManager.getGasStationReviews(reviewPanel.gasStationID)

            ratingView.positionViewAtBeginning()
            ratingView.forceLayout()
            ratingView.forceActiveFocus()

            reviews.setAverage()
        }

        anchors {
            top: title.bottom; bottom: controlRow.top; bottomMargin: 10
            left: reviewPanel.left; right: reviewPanel.right; margins: 5
        }
        spacing: 5

        opacity: enabled ? 1 : 0.5
        clip: true
        model: reviewsManager.getGasStationReviews(reviewPanel.gasStationID)

        delegate: Item {
            id: __rating
            
            width: ratingView.width
            height: Utils.perc(ratingView.height, 25)-ratingView.spacing

            Rectangle {
                anchors.fill: parent
                color: Theme.light
                
                radius: 5
            }
            RowLayout {
                id: ratingRow

                anchors.fill: parent
                spacing: 5

                Controls.Label {
                    Layout.preferredWidth: Utils.perc(ratingRow.width, 30)-ratingRow.spacing
                    Layout.preferredHeight: Utils.perc(ratingRow.height, 50)

                    fontSize: 20
                    fontFamily: "Phosphor"
                    text: Utils.getIcon(0xE46A).repeat(model.stelle)
                    textColor: Theme.highlight
                }
                Controls.Label {
                    Layout.preferredWidth: Utils.perc(ratingRow.width, 62.5)-ratingRow.spacing
                    Layout.fillHeight: true

                    text: String(model.idUtente + ((model.recensione === "") ? "" : (": " + model.recensione)))
                    horizontalAlignment: Text.AlignLeft
                }
                Controls.Button {
                    Layout.preferredWidth: Utils.perc(ratingRow.width, 7.5)-ratingRow.spacing
                    Layout.fillHeight: true

                    iconCode: Utils.getIcon(0xE4A6)
                    enabled: ((reviewPanel.gasStationID !== -1) && (reviewPanel.userID !== "") && (reviewsManager.isReviewOwner(model.idValutazione, reviewPanel.userID)))
                    opacity: enabled ? 1 : 0
                    onClicked: {
                        var check = reviewsManager.deleteReview(model.idValutazione, reviewPanel.userID)
                        
                        if(!check) return
                        ratingView.refreshRatings()
                    }
                }
            }
        }
    }

    RowLayout {
        id: controlRow

        visible: false

        height: Utils.perc(parent.height, 15)
        anchors {
            bottom: parent.bottom; bottomMargin: 5
            left: parent.left; leftMargin: 5
            right: parent.right; rightMargin: 5
        }

        spacing: 5

        Controls.ComboBox {
            id: starBox
            
            Layout.preferredWidth: Utils.perc(parent.width, 30)-parent.spacing
            Layout.fillHeight: true

            fontSize: 16
            fontFamily: "Phosphor"
            currentIndex: 0
            model: [
                "",
                Utils.getIcon(0xE46A),
                Utils.getIcon(0xE46A).repeat(2),
                Utils.getIcon(0xE46A).repeat(3),
                Utils.getIcon(0xE46A).repeat(4),
                Utils.getIcon(0xE46A).repeat(5)
            ]
        }
        Controls.TextField {
            id: reviewText

            Layout.preferredWidth: Utils.perc(parent.width, 60)-parent.spacing
            Layout.fillHeight: true

            text: ""
            fontSize: 10
            placeholder: "Write Your Review..."
            maximumLength: 250
        }
        Controls.Button {
            Layout.preferredWidth: Utils.perc(parent.width, 10)-parent.spacing
            Layout.fillHeight: true

            iconCode: Utils.getIcon(0xE3D4)
            onClicked: {
                var check = reviewsManager.addReview(reviewPanel.gasStationID, reviewPanel.userID, starBox.currentIndex, reviewText.text)
                
                if(check) {
                    ratingView.refreshRatings()
                    addRating.enabled = ((reviewPanel.gasStationID !== -1) && (reviewPanel.userID !== "") && (reviewsManager.canAddReview(reviewPanel.gasStationID, reviewPanel.userID)))
                }
                addRating.checked = false
            }
        }
    }

    onVisibleChanged: {
        starBox.currentIndex = 0
        reviewText.text = ""
        controlRow.visible = false

        ratingView.enabled = true
        if(visible) ratingView.refreshRatings()
    }
    Reviews { id: reviewsManager }
}