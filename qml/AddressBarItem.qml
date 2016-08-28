import QtQuick 2.0

import LunaNext.Common 0.1

import "AppTweaks"
import "Utils"

Item {
    id: addressBarItem

    property Item webViewItem
    property alias addressBarText: addressBarTextInput.text

    signal commitURL(string newURL);

    Row {
        height: parent.height

        //This one is nasty, but to due QML limitations need to use 3 images for this.
        Image {
            id: leftAddressBar
            height: parent.height
            width: Units.gu(1)
            source: "images/input-tool-left.png"
        }

        Image {
            id: centerAddressBar
            height: parent.height
            width: addressBarItem.width - leftAddressBar.width - rightAddressBar.width
            fillMode: Image.Stretch
            source: "images/input-tool-center.png"

            TextInput {
                id: addressBarTextInput
                anchors.left: parent.left
                anchors.right: faviconImage.left
                anchors.verticalCenter: parent.verticalCenter

                clip: true
                height: Units.gu(3.5)
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
                inputMethodHints: Qt.ImhUrlCharactersOnly
                color: AppTweaks.privateByDefaultTweakValue ? "#2E8CF7" : "#E5E5E5"
                selectedTextColor: "#000000"
                selectionColor: "#ADAD15"
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignLeft
                focus: true
                text: ""

                state: ""

                onAccepted: commitURL(addressBarTextInput.text)
                onFocusChanged: {
                    searchSuggestions.visible = false
                }

                onActiveFocusChanged: {
                    Qt.inputMethod.show()
                    if (addressBarTextInput.text === "" && webViewItem.url !== "") {
                        addressBarTextInput.text = webViewItem.url
                    }
                }

                Component.onCompleted: {
                    if (webViewItem.url != "") {
                        addressBarTextInput.focus = false
                    }
                }

                Text {
                    anchors.fill: addressBarTextInput
                    font.family: "Prelude"
                    font.pixelSize: addressBarTextInput.font.pixelSize
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: addressBarTextInput.color
                    text: "Enter URL or search terms"
                    visible: addressBarTextInput.visible && !addressBarTextInput.activeFocus && addressBarTextInput.text === ""
                }

                Binding {
                    when: webView.loading
                    target: addressBarTextInput
                    property: "text"
                    value: webViewItem.url
                }

                MouseArea {
                    anchors.fill: parent

                    // here's the WebOS 3.0 text selection behavior
                    // on clic:
                    //  If entry is unfocused --> focus + selectAll
                    //  clic on selected text --> show actions Copy/Cut/(Paste if clipboard non empty)
                    //  If actions are shown --> unselect all + position cursor
                    //  If already focused but no selection --> position cursor
                    // on long press
                    //  focused but no selection --> Select/SelectAll/(Paste if clipboard non empty)

                    onClicked: {
                        if (!addressBarTextInput.focus) {
                            addressBarTextInput.focus = true
                            addressBarTextInput.selectAll()
                        }
                        else {
                            // did the click occur inside the selection?
                            var clicPos = addressBarTextInput.positionAt(mouse.x);
                            if (clicPos>=addressBarTextInput.selectionStart && clicPos<addressBarTextInput.selectionEnd) {
                                // clic on current selection
                                if (cutCopyPasteOverlay.actionsVisible) {
                                    cutCopyPasteOverlay.hideActions();
                                    addressBarTextInput.deselect();
                                    addressBarTextInput.cursorPosition = clicPos;
                                }
                                else {
                                    cutCopyPasteOverlay.showCutCopy();
                                }
                            }
                            else {
                                // clic outside of current selection
                                cutCopyPasteOverlay.hideActions();
                                addressBarTextInput.cursorPosition = clicPos;
                            }
                        }
                    }

                    onPressAndHold: {
                        if (!addressBarTextInput.selectedText && !cutCopyPasteOverlay.actionsVisible) {
                            addressBarTextInput.cursorPosition = addressBarTextInput.positionAt(mouse.x)
                            cutCopyPasteOverlay.showSelectSelectAll();
                        }
                        else if(!cutCopyPasteOverlay.actionsVisible) {
                            cutCopyPasteOverlay.showCutCopy();
                        }
                    }
                }
            }

            CutCopyPasteTextEntryOverlay {
                id: cutCopyPasteOverlay
                textEntry:addressBarTextInput

                anchors.fill: addressBarTextInput
            }

            Image {
                id: faviconImage
                anchors.right: loadingIndicator.left
                anchors.verticalCenter: parent.verticalCenter
                source: webView.icon
                width: Units.gu(2.4)
                height: Units.gu(2.4)
            }

            Image {
                id: loadingIndicator

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: Units.gu(3.75)
                width: Units.gu(3.75)
                clip: true
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignTop
                source: webView.loading ? "images/menu-icon-stop.png" : "images/menu-icon-refresh.png"

                //Handle stop/reload
                MouseArea {
                    anchors.fill: loadingIndicator

                    onClicked: {
                        if (!webView.loading) {
                            webView.reload()
                        } else {
                            webView.stop()
                            if (addressBarTextInput.selectedText !== "") {
                                addressBarTextInput.deselect();
                                addressBarTextInput.focus = true
                                addressBarTextInput.text = ""
                                Qt.inputMethod.show()
                            }
                        }
                    }
                }
            }
        }

        Image {
            id: rightAddressBar
            height: parent.height
            width: Units.gu(1)
            source: "images/input-tool-right.png"
        }
    }
}
