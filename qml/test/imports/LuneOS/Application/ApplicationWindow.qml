import QtQuick 2.1
import "."

Item {
    id: window

    property int type: 0
    property int parentWindowId: 0

    signal closed
}
