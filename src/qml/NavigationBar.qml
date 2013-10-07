import QtQuick 2.0

Rectangle {
    id: navigationBar

    property string currentUrl: ""
    property Item webView

    color: "#efefef"
    height: 38
    z: webView.z + 1
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }

    Rectangle {
        color: "white"
        height: 26
        border.width: 1
        border.color: "#bfbfbf"
        radius: 3
        anchors {
            left: parent.left
            right: parent.right
            margins: 6
            verticalCenter: parent.verticalCenter
        }
        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            radius: 3
            width: parent.width / 100 * Math.max(5, webView.loadProgress)
            color: "blue"
            opacity: 0.3
            visible: webView.loading
        }
        Image {
            id: favIcon
            source: webView.icon != '' ? webView.icon : '../icons/favicon.png'
            width: 16
            height: 16
            anchors {
                left: parent.left
                leftMargin: 6
                verticalCenter: parent.verticalCenter
            }
        }
        TextInput {
            id: addressLine
            clip: true
            selectByMouse: true
            horizontalAlignment: TextInput.AlignLeft
            font {
                pointSize: 11
                family: "Sans"
            }
            anchors {
                verticalCenter: parent.verticalCenter
                left: favIcon.right
                right: parent.right
                margins: 6
            }

            Keys.onReturnPressed:{
                console.log("Navigating to: ", addressLine.text)
                load(utils.urlFromUserInput(addressLine.text))
            }

            property url url: navigationBar.currentUrl

            onUrlChanged: {
                if (activeFocus)
                    return;

                text = url
                cursorPosition = 0
            }

            onActiveFocusChanged: url = webView.url
        }
    }
}
