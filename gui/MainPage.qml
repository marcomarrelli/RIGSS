import QtQuick 2.15
import QtQuick.Controls 2.15

import QtLocation 5.15
import QtPositioning 5.15

import ApplicationSettings 1.0
import GasStations 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: mainPage

    property string username: ""
    readonly property real radius: 25

    GasStationsMap {
        id: gasStationMap

        width: Utils.perc(parent.width, 70)

        anchors {
            top: parent.top; topMargin: 25
            bottom: parent.bottom; bottomMargin: 25
            left: parent.left; leftMargin: 25
        }

        mapRadius: mainPage.radius

        username: mainPage.username
        gasStations: gasStationsData
    }

    ControlSection {
        id: controlPanel

        visible: true
        anchors {
            top: parent.top; topMargin: 25
            bottom: parent.bottom; bottomMargin: 25
            left: gasStationMap.right; leftMargin: 50
            right: parent.right; rightMargin: 25
        }

        backgroundRadius: mainPage.radius

        username: mainPage.username
        gasStations: gasStationsData
        onGasStationSelected: (gasStation) => gasStationMap.goTo(gasStation)
        onOpenUserPage: {
            controlPanel.visible = false
            userPanel.visible = true
        }
    }

    UserPage {
        id: userPanel

        visible: false
        anchors {
            top: parent.top; topMargin: 25
            bottom: parent.bottom; bottomMargin: 25
            left: gasStationMap.right; leftMargin: 50
            right: parent.right; rightMargin: 25
        }

        backgroundRadius: mainPage.radius

        username: mainPage.username
        gasStations: gasStationsData

        onAdd: gasStationEditor.show()
        onAddFuels: (gasStation) => fuelEditor.show(gasStation)
        onEdit: (gasStation) => gasStationEditor.show(gasStation)
        onRemove: (gasStation) => {
            var check = gasStationsData.deleteGasStation(gasStation.idImpianto)
            if(check) userPanel.refreshModel()
        }

        onClose: {
            userPanel.visible = false
            controlPanel.visible = true
        }
    }

    Popup {
        id: gasStationEditor

        function show(gasStation = undefined) {
            gasStationEditor.open()
            if(Utils.exists(gasStation)) editorPanel.gasStation = gasStation
        }

        width: Utils.perc(parent.width, 45)
        height: Utils.perc(parent.height, 90)

        anchors.centerIn: parent

        focus: true
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle { color: "transparent" }
        contentItem: GasStationEditor {
            id: editorPanel

            gasStationManager: gasStationsData
            usernameGestore: userPanel.username
            onGetMapCenter: editorPanel.setPosition(gasStationMap.center ?? gasStationMap.centerCoordinates)
        }

        onClosed: userPanel.refreshModel()
    }

    Popup {
        id: fuelEditor

        function show(gasStation = undefined) {
            fuelEditor.open()
            if(Utils.exists(gasStation)) fuelPanel.gasStation = gasStation
        }

        width: Utils.perc(parent.width, 45)
        height: Utils.perc(parent.height, 90)

        anchors.centerIn: parent

        focus: true
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle { color: "transparent" }
        contentItem: FuelEditor {
            id: fuelPanel

            gasStationManager: gasStationsData
        }

        onClosed: userPanel.refreshModel()
    }

    GasStations { id: gasStationsData }
}
