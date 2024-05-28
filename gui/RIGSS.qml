import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import QtLocation 5.15
import QtPositioning 5.15
import QtGraphicalEffects 1.12

import ApplicationSettings 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

ApplicationWindow {
    id: rigss

    property int userPrivilage: RIGSS.Privilage.NotLogged // TO DO: Change
    readonly property string applicationTitle: { // TO DO: Logged In as Admin/User/Not Logged In
        switch(rigss.userPrivilage) {
            case RIGSS.Privilage.NotLogged: return qsTr("RIGSS [Not Logged In]")
            case RIGSS.Privilage.User: return qsTr("RIGSS [Logged In as User]")
            case RIGSS.Privilage.Admin: return qsTr("RIGSS [Logged In as Admin]")
        }
    }

    minimumWidth: Utils.perc(Screen.width, 70)
    minimumHeight: Utils.perc(Screen.height, 70)

    title: rigss.applicationTitle

    visible: true
    visibility: Window.Maximized

    enum Privilage {
        NotLogged,
        User,
        Admin
    }

    header: ApplicationHeader {
        parentWindow: rigss
        width: rigss.width
        height: Utils.perc(rigss.height, 5)
    }

    background: Rectangle { color: Theme.dark }

    // StackView {
    //     anchors.fill: parent
    // }

    LoginPage {
        id: mainPagePanel

        anchors.fill: parent
    }
    
    Component.onCompleted: rigss.show()
}

/*
ApplicationWindow {
    id: root

    component GasStationDelegate : MapQuickItem {
        anchorPoint: Qt.point(gasStationItem.width/2, gasStationItem.height/2)

        sourceItem: Rectangle {
            id: gasStationItem

            width: 15
            height: 15

            radius: width/2

            color: "orange"
        }
    }

    MapItemView {
        id: gasStationView

        model: gasStationModel
        delegate: GasStationDelegate {
            coordinate: QtPositioning.coordinate(latitude, longitude)
        }
    }

    ListModel {
        id: gasStationModel

        ListElement {
            latitude: 41.9027835
            longitude: 12.4963655
        }
        ListElement {
            latitude: 38.9027835
            longitude: 10.4963655
        }
        ListElement {
            latitude: 43.9027835
            longitude: 15.4963655
        }
        ListElement {
            latitude: 44.351862
            longitude: 12.257578
        }
    }

    Component.onCompleted: visible = true
}
*/
