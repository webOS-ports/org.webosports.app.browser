import QtQuick 2.0

import LunaNext.Common 0.1

import "js/util.js" as EnyoUtils

import "AppTweaks"

Item {
    id: addressBarItem

    property alias addressBarText: addressBarTextInput.text

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

                onAccepted: updateURL()
                onFocusChanged: {
                    searchSuggestions.visible = false
                }

                onActiveFocusChanged: {
                    Qt.inputMethod.show()
                    if (addressBarTextInput.text === "" && webViewItem.url !="") {
                        addressBarTextInput.text = webViewItem.url
                    }
                }

                Component.onCompleted: {
                    if (webViewItem.url != "") {
                        addressBarTextInput.focus = false
                    }
                }

                onContentSizeChanged: {
                    //We need a different query in case the lenght is 0
                    if (addressBarTextInput.text.length === 0) {
                    //    navigationBar.__queryDB(
                    //                "find",
                    //                '{"query":{"from":"com.palm.browserbookmarks:1"}}')
                    } else {
                        navigationBar.__queryDB(
                                    "search",
                                    '{"query":{"from":"com.palm.browserbookmarks:1", "where":[{"prop":"searchText", "op":"?", "val":'
                                    + "\"" + addressBarTextInput.text + "\""
                                    + ', "collate":"primary"}], "orderBy": "_rev", "desc": true}}')
                    }
                    searchSuggestions.optSearchText = defaultSearchDisplayName
                    searchSuggestions.defaultSearchIcon = defaultSearchIcon
                    searchSuggestions.height = (searchSuggestions.urlModelCount + 1) * Units.gu(
                                6)
                    searchSuggestions.suggestionListHeight = searchSuggestions.urlModelCount * Units.gu(
                                6)
                    if (addressBarTextInput.text.length === 0 || addressBarTextInput.text.substring(
                                0,
                                4) === "http" || addressBarTextInput.text.substring(0,
                                                                           3) === "ftp"
                            || addressBarTextInput.text.substring(0, 4) === "data" || addressBarTextInput.text.substring(
                                0,
                                4) === "file") {
                        searchSuggestions.visible = false
                    } else {
                        searchSuggestions.visible = true
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

                //TODO Dirty function for prefixing with http:// for now. Would be good if we can detect if site can do https and use that or else http
                function updateURL() {
                    searchSuggestions.visible = false
                    var uri = EnyoUtils.parseUri(addressBarTextInput.text)
                    if ((EnyoUtils.isValidScheme(uri) && EnyoUtils.isUri(
                             addressBarTextInput.text,
                             uri))) {
                        if (text.substring(0, 7).toLowerCase() === "http://" || text.substring(
                                    0,
                                    8).toLowerCase() === "https://" || text.substring(0,
                                                                        6).toLowerCase() === "ftp://"
                                || text.substring(0, 7).toLowerCase() === "data://" || text.substring(0, 7).toLowerCase() === "file://" || text.substring(0, 6).toLowerCase() === "about:") {
                            webView.url = addressBarTextInput.text

                            //Show the lock in case of https
                            if (text.substring(0, 8).toLowerCase() === "https://") {
                                isSecureSite = true
                            } else {
                                isSecureSite = false
                            }
                        } else {
                            webView.url = "http://" + addressBarTextInput.text
                            addressBarTextInput.text = "http://" + addressBarTextInput.text
                        }
                    } else {
                        //Just do a search with the default search engin
                        webView.url = defaultSearchURL.replace("#{searchTerms}",
                                                               addressBarTextInput.text)
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
