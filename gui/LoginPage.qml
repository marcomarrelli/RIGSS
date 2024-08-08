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

                text: "back"

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

                text: "go in"
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
            placeholder: "Insert Username"
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.TextField {
                id: registerName

                Layout.fillWidth: true
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "Insert Name"
            }
            Controls.TextField {
                id: registerSurname

                Layout.fillWidth: true
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "Insert Surname"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.TextField {
                id: registerDoB

                Layout.fillWidth: true
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "Insert Date of Birth"
            }
            Controls.TextField {
                id: registerPosition

                Layout.fillWidth: true
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                placeholder: "Insert Position"
            }
        }
        Controls.TextField {
            id: registerPassword

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Insert Password"
        }
        Controls.TextField {
            id: registerConfirmPassword

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Insert Repeat Password"
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.Button {
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-parent.spacing
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignLeft

                text: "back"

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
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-parent.spacing
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignRight

                text: "regstr"
            }
        }
    }
}
