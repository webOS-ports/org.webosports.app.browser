import QtQuick 2.1
import "."

Item {
    id: window

    property int type: 0
    property int parentWindowId: 0

    function show() {
        window.visible = true;
    }

    signal closed();
}
