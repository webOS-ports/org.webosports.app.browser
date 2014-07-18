import QtQuick 2.0
import QtQuick.Window 2.1
import QtWebKit 3.0

Window
{
    id: root

    flags: Qt.CustomizeWindowHint /* for sure we can even do better, see doc in Qt about that flag */

    /* Without this line, we won't ever see the window... */
    Component.onCompleted: root.visible = true;

    Flickable {
        id: flickableWebview

        anchors { fill: parent; topMargin: 50; leftMargin: 10; rightMargin: 10; bottomMargin: 10 }
        contentWidth: 800
        contentHeight: 1280
        boundsBehavior: Flickable.DragOverBounds
        clip: true

        WebView {
            id: webViewItem

            width: 800
            height: 1280

            url: "http://webos-ports.org/" // of course !
        }
    }
}
