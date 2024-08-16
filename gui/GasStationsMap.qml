import QtQuick 2.15
import QtQuick.Controls 2.15

import QtLocation 5.15
import QtPositioning 5.15

import QtGraphicalEffects 1.12

import "../logic/utils.js" as Utils

import GasStations 1.0

Map {
    id: map

    property real mapRadius: 25

    readonly property real minZoom: 6.0
    readonly property real maxZoom: 17.0

    readonly property var centerCoordinates: QtPositioning.coordinate(41.9027835, 12.4963655)
    
    function zoom(wheel) {
        if(!Utils.existsEvery(map, wheel)) return
        if(!Utils.existsEvery(map.zoomLevel, map.minimumZoomLevel, map.maximumZoomLevel)) return

        var newZoom = map.zoomLevel+(wheel.angleDelta.y*zoomHandler.rotationScale/2)

        if((newZoom < map.minimumZoomLevel) || (newZoom > map.maximumZoomLevel)) return
        else map.zoomLevel = newZoom
    }

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
    }

    // mapItems:
    MapItemView {
        model: gasStationsData.model
        delegate: MapQuickItem {
            property real itemSize: (map.zoomLevel*map.zoomLevel)/map.minZoom

            coordinate: QtPositioning.coordinate(model.latitudine, model.longitudine)
            sourceItem: Rectangle {
                width: itemSize; height: itemSize
                radius: width/2; color: "orange"
            }
        }
    }
    
    //gasStationsData.model.data(gasStationsData.model.index(0, 10), 0)
    //{
    //    var temp
    //    Object.keys(gasStationsData.model).forEach(e => temp += (e + "\n"))
    //    return temp
    //}

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

    GasStations {
        id: gasStationsData
    }
}