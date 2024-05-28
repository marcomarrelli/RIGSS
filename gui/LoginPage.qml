import QtQuick 2.15
import QtQuick.Controls 2.15 as C
import QtQuick.Layouts 1.15

import ApplicationSettings 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: loginPage

    property color backgroundColor: Theme.mid
    readonly property real radius: 25

    Rectangle {
        id: bodyBackground

        width: Utils.perc(parent.width, 30)
        height: Utils.perc(parent.height, 95)

        anchors.centerIn: parent

        color: loginPage.backgroundColor
        radius: 25
        border {
            color: Theme.border
            width: 1
        }
    }
    ColumnLayout {
        id: body

        anchors {
            fill: bodyBackground
            margins: Utils.perc(bodyBackground.width, 5)
        }
        spacing: 5

        Image {
            id: logo

            Layout.preferredWidth: Utils.perc(body.height, 50)-parent.spacing
            Layout.preferredHeight: Utils.perc(body.height, 50)-parent.spacing
            Layout.alignment: Qt.AlignHCenter

            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "./resources/rigss-no-bg.svg"
        }
        Controls.Button {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(body.height, 10)-parent.spacing

            text: "Login" // Username + Password
        }
        Controls.Button {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(body.height, 10)-parent.spacing

            text: "Register" // CF, Username, Password e Ripeti Password
        }
    }

    /*
        Controls.TextField {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(body.height, 10)
            placeholder: "Insert Username..."
        }
        Controls.TextField {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(body.height, 10)
            placeholder: "Insert Username..."
        }
    */
}
