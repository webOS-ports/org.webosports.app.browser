import QtQuick 2.0
import QtQuick.Window 2.1
import QtWebKit 3.0

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

    WebView {
        id: webViewItem

        anchors.fill: parent

        url: "http://webos-ports.org/" // of course !
    }
}
