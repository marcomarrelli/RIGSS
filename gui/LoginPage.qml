import QtQuick 2.15
import QtQuick.Controls 2.15 as C
import QtQuick.Layouts 1.15

import QtQuick.Controls 1.4 as OldC

import ApplicationSettings 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: loginPage

    property color backgroundColor: Theme.mid
    readonly property real radius: 25

    signal loggedSuccessfully()

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

            text: qsTr("Login") // Username + Password
            onClicked: {
                loginBody.visible = true
                registerBody.visible = false
                body.visible = false
            }
        }
        Controls.Button {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(body.height, 10)-parent.spacing

            text: qsTr("Register") // Username - [Nome - Cognome] - [DataNascita - Luogo] - [Password - Ripeti Password]
            onClicked: {
                loginBody.visible = false
                registerBody.visible = true
                body.visible = false
            }
        }
        Controls.Label {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(body.height, 10)-parent.spacing
            Layout.alignment: Qt.AlignHCenter

            text: qsTr("Enter without being logged or registered")
            hoverEnabled: true
            opacity: 0.75
            font.underline: true

            MouseArea {
                anchors.fill: parent
                onClicked: {

                }
            }
        }
    }

    ColumnLayout {
        id: loginBody

        anchors {
            fill: bodyBackground
            margins: Utils.perc(bodyBackground.width, 5)
        }
        spacing: 5

        visible: false

        Image {
            Layout.preferredWidth: Utils.perc(loginBody.height, 30)-parent.spacing
            Layout.preferredHeight: Utils.perc(loginBody.height, 30)-parent.spacing
            Layout.alignment: Qt.AlignHCenter

            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "./resources/rigss-no-bg.svg"
        }
        Controls.TextField {
            id: loginUsername

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Insert Username"
        }
        Controls.TextField {
            id: loginPassword

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Insert Password"
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.Button {
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-parent.spacing
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignLeft

                iconCode: Utils.getIcon(0xE024)

                onClicked: {
                    loginUsername.text = ""
                    loginPassword.text = ""
                    loginBody.visible = false
                    registerBody.visible = false
                    body.visible = true
                }
            }
            Controls.Button {
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-parent.spacing
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignRight

                iconCode: Utils.getIcon(0xE428)
            }
        }
    }

    ColumnLayout {
        id: registerBody

        anchors {
            fill: bodyBackground
            margins: Utils.perc(bodyBackground.width, 5)
        }
        spacing: 5

        visible: false

        Image {
            Layout.preferredWidth: Utils.perc(registerBody.height, 30)-parent.spacing
            Layout.preferredHeight: Utils.perc(registerBody.height, 30)-parent.spacing
            Layout.alignment: Qt.AlignHCenter

            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "./resources/rigss-no-bg.svg"
        }
        Controls.TextField {
            id: registerUsername

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Username"
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.TextField {
                id: registerName

                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-(parent.spacing/2)
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "Name"
            }
            Controls.TextField {
                id: registerSurname

                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-(parent.spacing/2)
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "Surname"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.TextField {
                id: registerDoB

                Layout.preferredWidth: Utils.perc(registerBody.width, 40)-(parent.spacing/2)
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "dd-mm-YYYY"
            }
            Controls.TextField {
                id: registerPosition

                Layout.preferredWidth: Utils.perc(registerBody.width, 60)-(parent.spacing/2)
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "Birthplace"
            }
        }
        Controls.TextField {
            id: registerPassword

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Password"
        }
        Controls.TextField {
            id: registerConfirmPassword

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Repeat Password"
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.Button {
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-(parent.spacing/2)
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignLeft

                iconCode: Utils.getIcon(0xE024)

                onClicked: {
                    registerUsername.text = ""
                    registerName.text = ""
                    registerSurname.text = ""
                    registerDoB.text = ""
                    registerPosition.text = ""
                    registerPassword.text = ""
                    registerConfirmPassword.text = ""
                    loginBody.visible = false
                    registerBody.visible = false
                    body.visible = true
                }
            }
            Controls.Button {
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-(parent.spacing/2)
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignRight

                iconCode: Utils.getIcon(0xEAFA)

                onClicked: {

                }
            }
        }
    }
}
