import QtQuick 2.0
import QtQuick.Window 2.1
import QtWebKit 3.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1

Window
{
    id: root

    width: 800
    height: 600

    /* Without this line, we won't ever see the window... */
    Component.onCompleted: root.visible = true;

    Connections {
        target: application // this is luna-qml-launcher C++ object instance
        onRelaunched: console.log("The browser has been relaunched with parameters: " + parameters);
    }

    NavigationBar {
        id: navigationBar
        webView: webViewItem
    }

    WebView {
        id: webViewItem
        anchors.top: pb2.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        url: "http://www.webos-ports.org" // of course !
    }

    ProgressBar {
        id: pb2
        property int minimum: 0
        property int maximum: 100
        property int value: 0
        indeterminate: true
        visible: true //simpletimer.running
        anchors.top: navigationBar.bottom
        style: ProgressBarStyle {
                background: Rectangle {
                    radius: 2
                    color: "lightgray"
                    border.color: "gray"
                    border.width: 1
                    implicitWidth: navigationBar.width
                    implicitHeight: Units.gu(1)
                }
                progress: Rectangle {
                    color: "lightsteelblue"
                    border.color: "steelblue"
                }
            }
    }
}
