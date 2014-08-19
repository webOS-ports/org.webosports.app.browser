import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1

Rectangle {
    id: navigationBar

    property Item webView: null

    width: parent.width
    height: Units.gu(5)
    color: "black"

    TextField {
        id: addressBar
        anchors.fill: parent

        Image {
            id: faviconImage
            anchors.verticalCenter: addressBar.verticalCenter
            source: webView && webView.icon
        }
        
        font.pixelSize: Units.gu(2)
        font.family: "Prelude"
        
        anchors.margins: Units.gu(1)
        focus: true
        text: webView && webView.url

        onAccepted: webView.url = text
    }

    Rectangle {
        color: "red"
        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
    }
}
