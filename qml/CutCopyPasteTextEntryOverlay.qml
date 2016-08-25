import QtQuick 2.0

import LunaNext.Common 0.1

Item {
    id: cutCopyPasteOverlayItem

    property TextInput textEntry
    property bool showCut: false
    property bool showCopy: false
    property bool showPaste: false
    property bool showSelect: false
    property bool showSelectAll: false

    property bool markerVisible: textEntry.selectedText.length>0
    property bool actionsVisible: showCut || showCopy || showPaste || showSelect || showSelectAll
    visible: markerVisible || actionsVisible

    // some helpers for the most common cases
    function showCutCopy() {
        showCut = true;
        showCopy = true;
        showPaste = _clipboardAccess.getClipboardContent().length>0;
        showSelect = false;
        showSelectAll = false;
    }
    function showSelectSelectAll() {
        showCut = false;
        showCopy = false;
        showPaste = _clipboardAccess.getClipboardContent().length>0;
        showSelect = true;
        showSelectAll = true;
    }
    function hideActions() {
        showCut = false;
        showCopy = false;
        showPaste = false;
        showSelect = false;
        showSelectAll = false;
    }

    Clipboard {
        id: _clipboardAccess
    }

    Image {
        id: topMarker
        source: "images/topmarker.png"
        visible: markerVisible
        y: -height + 8

        Connections {
            target: textEntry
            onSelectionStartChanged: {
                var startSelectionPosX = textEntry.positionToRectangle(textEntry.selectionStart).x;
                if(startSelectionPosX < 0) {
                    topMarker.x =  -(topMarker.width/2);
                }
                else {
                    topMarker.x = startSelectionPosX - (topMarker.width/2);
                }
            }
        }
    }

    Image {
        id: bottomMarker
        source: "images/bottommarker.png"
        visible: markerVisible
        y: textEntry.height - 8

        Connections {
            target: textEntry
            onSelectionEndChanged: {
                var endSelectionPosX = textEntry.positionToRectangle(textEntry.selectionEnd).x;
                if(endSelectionPosX < 0) {
                    bottomMarker.x =  -(topMarker.width/2);
                }
                else {
                    bottomMarker.x = endSelectionPosX - (topMarker.width/2);
                }
            }
        }
    }

    Row {
        id: overlayBackground
        visible: actionsVisible
        y: textEntry.height
        x: ((topMarker.x + bottomMarker.x + bottomMarker.width) / 2) - (overlayBackground.width / 2)

        Image {
            id: overlayBackgroundLeft
            source: "images/ate-left.png"
        }
        Image {
            source: "images/ate-middle.png"
            width: overlayContentRow.width/2 - overlayBackgroundArrowUp.width/2
        }
        Image {
            id: overlayBackgroundArrowUp
            source: "images/ate-arrow-up.png"
            anchors.bottom: overlayBackgroundLeft.bottom
            anchors.bottomMargin: 7
        }
        Image {
            source: "images/ate-middle.png"
            width: overlayContentRow.width/2 - overlayBackgroundArrowUp.width/2
        }
        Image {
            source: "images/ate-right.png"
        }
    }

    Row {
        id: overlayContentRow
        visible: actionsVisible
        anchors.centerIn: overlayBackground
        anchors.verticalCenterOffset: -6

        spacing: 6

        Text {
            id: cutCopyPasteTextCut
            text: "Cut"
            anchors.verticalCenter: overlayContentRow.verticalCenter
            font.family: "Prelude"
            font.weight: Font.DemiBold
            font.pixelSize: FontUtils.sizeToPixels("medium")
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    textEntry.cut()
                    cutCopyPasteOverlayItem.hideActions();
                }
            }

            visible: cutCopyPasteOverlayItem.showCut
        }
        Image {
            source: "images/ate-divider.png"
            anchors.verticalCenter: overlayContentRow.verticalCenter

            visible: cutCopyPasteTextCut.visible && cutCopyPasteTextCopy.visible
        }
        Text {
            id: cutCopyPasteTextCopy
            text: "Copy"
            anchors.verticalCenter: overlayContentRow.verticalCenter
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
            font.weight: Font.DemiBold
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    textEntry.copy()
                    cutCopyPasteOverlayItem.hideActions();
                }
            }

            visible: cutCopyPasteOverlayItem.showCopy
        }
        Image {
            source: "images/ate-divider.png"
            anchors.verticalCenter: overlayContentRow.verticalCenter

            visible: cutCopyPasteTextCopy.visible && cutCopyPasteTextPaste.visible
        }
        Text {
            id: cutCopyPasteTextPaste
            text: "Paste"
            anchors.verticalCenter: overlayContentRow.verticalCenter
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
            font.weight: Font.DemiBold
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    textEntry.paste()
                    cutCopyPasteOverlayItem.hideActions();
                }
            }

            visible: cutCopyPasteOverlayItem.showPaste
        }
        Image {
            source: "images/ate-divider.png"
            anchors.verticalCenter: overlayContentRow.verticalCenter

            visible: cutCopyPasteTextPaste.visible && selectSelectAllTextSelect.visible
        }
        Text {
            id: selectSelectAllTextSelect
            text: "Select"
            anchors.verticalCenter: overlayContentRow.verticalCenter
            font.family: "Prelude"
            font.weight: Font.DemiBold
            font.pixelSize: FontUtils.sizeToPixels("medium")
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    textEntry.selectWord()
                    cutCopyPasteOverlayItem.hideActions();
                }
            }

            visible: cutCopyPasteOverlayItem.showSelect
        }
        Image {
            source: "images/ate-divider.png"
            anchors.verticalCenter: overlayContentRow.verticalCenter

            visible: selectSelectAllTextSelect.visible && selectSelectAllTextSelectAll.visible
        }
        Text {
            id: selectSelectAllTextSelectAll
            text: "Select All"
            anchors.verticalCenter: overlayContentRow.verticalCenter
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
            font.weight: Font.DemiBold
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    textEntry.selectAll()
                    cutCopyPasteOverlayItem.hideActions();
                }
            }

            visible: cutCopyPasteOverlayItem.showSelectAll
        }
    }
}
