import QtQuick 2.15
import QtQuick.Controls 2.15

import QtLocation 5.15
import QtPositioning 5.15

import QtGraphicalEffects 1.12

import "./controls" as Controls
import "../logic/utils.js" as Utils

Map {
    id: map

    property real mapRadius: 25

    readonly property real minZoom: 6.25
    readonly property real maxZoom: 16.75

    property var gasStations

    readonly property var centerCoordinates: QtPositioning.coordinate(41.9027835, 12.4963655)
    
    signal gasStationSelected(gasStation: var)

    function zoom(wheel) {
        if(!Utils.existsEvery(map, wheel)) return
        if(!Utils.existsEvery(map.zoomLevel, map.minimumZoomLevel, map.maximumZoomLevel)) return

        var newZoom = map.zoomLevel+(wheel.angleDelta.y*zoomHandler.rotationScale/2)

        if((newZoom < map.minimumZoomLevel) || (newZoom > map.maximumZoomLevel)) return
        else map.zoomLevel = newZoom
    }

    function goTo(gasStation = undefined) {
        if(!gasStation) return map.centerCoordinates

        map.center = QtPositioning.coordinate(gasStation.latitudine, gasStation.longitudine)
    }

    function showFuels(gasStation = undefined) {
        if(!gasStation) return map.centerCoordinates

        fuelsPopup.show(gasStation)
    }

    activeMapType: map.supportedMapTypes[map.supportedMapTypes.length-1]
    width: 500
    height: 500

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: map.width
            height: map.height
            radius: map.mapRadius
        }
    }

    minimumZoomLevel: map.minZoom
    maximumZoomLevel: map.maxZoom

    center: map.centerCoordinates
    zoomLevel: (map.minZoom+map.maxZoom)/2

    plugin: Plugin {
        name: "osm"

        PluginParameter { name: "osm.mapping.highdpi_tiles"; value: "true" }
        PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: "true" }
        PluginParameter { name: "osm.mapping.providersrepository.address"; value: "http://maps-redirect.qt.io/osm/5.8/" }
        PluginParameter { name: "osm.mapping.custom.host"; value: "https://tile.openstreetmap.org/" }
    }

    MapItemView {
        model: map.gasStations.model
        delegate: MapQuickItem {
            property real itemSize: map.zoomLevel*(map.maxZoom/map.minZoom)*0.75

            anchorPoint.x: itemSize/2
            anchorPoint.y: itemSize/2

            coordinate: QtPositioning.coordinate(model.latitudine, model.longitudine)
            sourceItem: GasStationMapItem {
                id: __gasStationMapItem

                simulated: model.simulato
                size: itemSize

                onClicked: map.showFuels(model)
            }
        }
    }

    DragHandler {
        id: drag

        target: map
        acceptedButtons: Qt.RightButton
        onTranslationChanged: (delta) => {
            if(delta) map.pan(-delta.x, -delta.y)
        }
    }

    WheelHandler {
        id: zoomHandler

        rotationScale: 1/120
        onWheel: (wheel) => map.zoom(wheel)
    }

    Popup {
        id: fuelsPopup

        function show(gasStation) {
            if(!gasStation) return

            var fuelList = map.gasStations.getFuels(gasStation.idImpianto)
            fuelLabel.text = ""

            if(fuelList.length === 0) fuelLabel.text = "No Fuels Available!"
            else {
                for(var f=0; f<fuelList.length; f++) {
                    var fuel = fuelList[f]
                    fuelLabel.text += fuel[3] ? (fuel[1] + " (Self): " + fuel[2] + "\n") : (fuel[1] + " (Servito): " + fuel[2] + "\n")
                }
            }

            fuelsPopup.open()
        }

        width: Utils.perc(parent.width, 50)
        height: Utils.perc(parent.height, 50)

        anchors.centerIn: parent

        focus: true
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            anchors.fill: parent
            color: Theme.dark
            border {
                color: Theme.border
                width: 1
            }
            radius: 25
        }
        contentItem: Controls.Label { id: fuelLabel }
    }
}