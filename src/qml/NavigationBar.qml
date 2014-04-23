import QtQuick 2.0
import LunaNext.Common 0.1

Rectangle {
    id: navigationBar

    property string currentUrl: ""
    property Item webView

    color: "#efefef"

    Rectangle {
        color: "white"
        border.width: 1
        border.color: "#bfbfbf"
        radius: 3
        anchors {
            fill: parent
            margins: 6
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
            width: Units.gu(2)
            height: Units.gu(2)
            anchors {
                left: parent.left
                leftMargin: Units.gu(1)
                verticalCenter: parent.verticalCenter
            }
        }

        TextInput {
            id: addressLine
            clip: true
            selectByMouse: true
            horizontalAlignment: TextInput.AlignLeft
            font {
                pointSize: FontUtils.sizeToPixels("small")
                family: "Prelude"
            }
            anchors {
                verticalCenter: parent.verticalCenter
                left: favIcon.right
                right: parent.right
                margins: Units.gu(1)
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
