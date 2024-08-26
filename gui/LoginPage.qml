import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtQuick.Controls 1.4 as OldC

import ApplicationSettings 1.0

import Users 1.0

import "./controls" as Controls
import "../logic/utils.js" as Utils

Item {
    id: loginPage

    property color backgroundColor: Theme.mid
    readonly property real radius: 25

    signal loggedSuccessfully(privilage: int, username: string)

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
                onClicked: loginPage.loggedSuccessfully(RIGSS.Privilage.NotLogged, "")
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
            placeholder: "Username"
        }
        Controls.TextField {
            id: loginPassword

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Password"

            echoMode: TextInput.Password
            passwordMaskDelay: 500
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.Button {
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-parent.spacing
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
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
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                Layout.alignment: Qt.AlignRight

                iconCode: Utils.getIcon(0xE428)
                onClicked: {
                    if(loginUsername.text === "") {
                        errorPopup.show("Please Insert Username.")
                        return
                    }
                    else if(loginPassword.text === "") {
                        errorPopup.show("Please Insert Password.")
                        return
                    }

                    var temp = usersData.login(loginUsername.text, loginPassword.text)
                    var check = temp[0]
                    var error = temp[1]

                    errorPopup.show(error, (check ? loginPage.loggedSuccessfully : undefined), RIGSS.Privilage.User, loginUsername.text)
                }
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

            echoMode: TextInput.Password
            passwordMaskDelay: 500
        }
        Controls.TextField {
            id: registerConfirmPassword

            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)
            placeholder: "Repeat Password"

            echoMode: TextInput.Password
            passwordMaskDelay: 500
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Utils.perc(registerBody.height, 10)

            Controls.Button {
                Layout.preferredWidth: Utils.perc(registerBody.width, 50)-(parent.spacing/2)
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
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
                Layout.preferredHeight: Utils.perc(registerBody.height, 10)
                Layout.alignment: Qt.AlignRight

                iconCode: Utils.getIcon(0xEAFA)

                onClicked: {
                    if(registerUsername.text === "") {
                        errorPopup.show("Error! Nickname Must Not be Blank.")
                        return
                    }
                    else if(usersData.userExists(registerUsername.text)) {
                        errorPopup.show("Error! Nickname Already in Use.")
                        return
                    }
                    else if(registerName.text === "") {
                        errorPopup.show("Error! Name Must Not be Blank.")
                        return
                    }
                    else if(registerSurname.text === "") {
                        errorPopup.show("Error! Surname Must Not be Blank.")
                        return
                    }
                    else if(registerPassword.text === "") {
                        errorPopup.show("Error! Password Must Not be Blank.")
                        return
                    }
                    else if(registerConfirmPassword.text === "") {
                        errorPopup.show("Error! Password Must be Confirmed.")
                        return
                    }
                    else if(registerPassword.text !== registerConfirmPassword.text) {
                        errorPopup.show("Error! Password Not Confirmed Properly.")
                        return
                    }
                    
                    if(!registerPassword.text.match(/[a-z]/)) {
                        errorPopup.show("Password Must Contain at Least One Lowercase Character.")
                        return
                    }
                    else if(!registerPassword.text.match(/[A-Z]/)) {
                        errorPopup.show("Password Must Contain at Least One Uppercase Character.")
                        return
                    }
                    else if(!registerPassword.text.match(/[0-9]/)) {
                        errorPopup.show("Password Must Contain at Least One Number.")
                        return
                    }
                    else if(registerPassword.text.match(/^([a-zA-Z0-9]+)$/)) {
                        errorPopup.show("Password Must Contain at Least One Special Character.")
                        return
                    }
                    else if(registerPassword.text.length < 5) {
                        errorPopup.show("Password Must be at Least 5 Characters Long.")
                        return
                    }

                    var check = usersData.addUser(registerUsername.text, registerName.text, registerSurname.text, registerDoB.text, registerPosition.text, registerPassword.text)
                    
                    if(check) errorPopup.show("User '" + registerUsername.text + "' Registered Successfully!", loginPage.loggedSuccessfully, RIGSS.Privilage.User, registerUsername.text)
                    else errorPopup.show("Error! Couldn't Add User.")
                }
            }
        }
    }

    Popup {
        id: errorPopup

        property alias error: errorLabel.text
        property var callbackFunction: undefined
        
        property int privilage: RIGSS.Privilage.NotLogged
        property string username: ""

        function show(errorText = "", callback = undefined, privilage = RIGSS.Privilage.NotLogged, username = "") {
            if(errorText === "") return

            errorPopup.error = errorText
            errorPopup.open()

            errorPopup.callbackFunction = undefined
            
            if(!Utils.exists(callback)) return
            errorPopup.callbackFunction = callback
            errorPopup.privilage = privilage
            errorPopup.username = username
        }

        width: Utils.perc(parent.width, 50)
        height: Utils.perc(parent.height, 30)

        anchors.centerIn: parent

        focus: true
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            id: errorBackground
            
            anchors.fill: parent
            color: Theme.dark
            border {
                color: Theme.border
                width: 1
            }
            radius: 25
        }
        contentItem: Controls.Label { id: errorLabel; font.bold: true }

        onClosed: if(Utils.exists(errorPopup.callbackFunction)) errorPopup.callbackFunction(errorPopup.privilage, errorPopup.username)
    }

    Users { id: usersData }
}
