/*
* Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
* Copyright (C) 2014 Herman van Hazendonk <github.com@herrie.org>
* Copyright (C) 2014 Christophe Chapuis <chris.chapuis@gmail.com>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

import QtQuick 2.0
import QtQuick.Window 2.1

import LunaNext.Common 0.1

import LuneOS.Service 1.0

Rectangle {
    id: sidePanelRoot

    visible: false
    enabled: visible
    color: "#E5E5E5"

    signal goToURL(string url);
    signal addBookmark();
    signal editBookmark(string url, string title, string icon, string id);

    property BookmarkDbModel  bookmarksDbModel
    property HistoryDbModel   historyDbModel
    property DownloadsDbModel downloadsDbModel

    function show() {
        visible = true;
    }
    function hide() {
        visible = false;
    }

    MouseArea {
        anchors.fill: parent
    }

    property string dataMode: "bookmarks"

    Rectangle {
        id: sidePanelHeader
        height: Units.gu(5.2)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#343434"
        Row {
            id: buttonRow
            anchors.left: parent.left
            anchors.right: parent.right
            height: Units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Units.gu(1)
            anchors.rightMargin: Units.gu(1)

            Item {
                id: bookmarkButton
                implicitWidth: buttonRow.width/3
                implicitHeight: Units.gu(4)

                Image {
                    id: bookmarkButtonImage
                    source: dataMode === "bookmarks" ? "images/radiobuttondarkleftpressed.png" : "images/radiobuttondarkleft.png"
                    anchors.fill: parent
                    anchors.left: bookmarkButton.left
                    MouseArea {
                        anchors.fill: bookmarkButtonImage
                        onClicked: dataMode = "bookmarks"
                    }

                    Image {
                        id: bookmarkButtonImageInside
                        source: "images/toaster-icon-bookmarks.png"
                        height: Units.gu(4)
                        width: Units.gu(4)
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        verticalAlignment: dataMode === "bookmarks" ? Image.AlignBottom : Image.AlignTop
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Item {
                id: historyButton
                implicitWidth: buttonRow.width/3
                implicitHeight: Units.gu(4)
                Image {
                    id: historyButtonImage
                    anchors.fill: parent
                    source: dataMode === "history" ? "images/radiobuttondarkmiddlepressed.png" : "images/radiobuttondarkmiddle.png"
                    anchors.left: parent.left

                    MouseArea {
                        anchors.fill: historyButtonImage
                        onClicked: dataMode = "history"
                    }

                    Image {
                        id: historyButtonImageInside
                        source: "images/toaster-icon-history.png"
                        height: Units.gu(4)
                        width: Units.gu(4)
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        verticalAlignment: dataMode === "history" ? Image.AlignBottom : Image.AlignTop
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            Item {
                id: downloadButton
                implicitWidth: buttonRow.width/3
                implicitHeight: Units.gu(4)
                Image {
                    id: downloadButtonImage
                    source: dataMode === "downloads" ? "images/radiobuttondarkrightpressed.png" : "images/radiobuttondarkright.png"
                    anchors.fill: parent
                    anchors.left: parent.left

                    MouseArea {
                        anchors.fill: downloadButtonImage
                        onClicked: dataMode = "downloads"
                    }

                    Image {
                        id: downloadButtonImageInside
                        source: "images/toaster-icon-downloads.png"
                        height: Units.gu(4)
                        width: Units.gu(4)
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        verticalAlignment: dataMode === "downloads" ? Image.AlignBottom : Image.AlignTop
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    Rectangle {
        id: sidePanelBody
        height: parent.height - sidePanelHeader.height - sidePanelFooter.height
        width: parent.width
        color: "#E5E5E5"
        anchors.top: sidePanelHeader.bottom

        ListView {
            anchors.top: sidePanelBody.top
            clip: true
            id: dataList
            width: parent.width
            height: parent.height

            model: dataMode === "history" ? historyDbModel:
                   dataMode === "bookmarks" ? bookmarksDbModel: undefined

            delegate:
            Item {
                id: dataSectionRect
                height: Units.gu(6)
                width: parent.width
                anchors.left: parent.left

                Rectangle {
                    id: dataResultsRect
                    height: Units.gu(6)
                    anchors.left: dataSectionRect.left
                    anchors.top: parent.top
                    color: "transparent"
                    width: dataMode === "history" ? Units.gu(4) : dataMode === "bookmarks" ? Units.gu(6) : Units.gu(1)

                    Image {
                        id: dataResultsImage
                        source: dataMode === "history" ? "images/header-icon-history.png" : dataMode === "bookmarks" ? (model.icon64||"") : ""
                        anchors.top: dataResultsRect.top
                        anchors.left: dataResultsRect.left
                        height: dataMode === "history" ? Units.gu(3) : Units.gu(5)
                        width: dataMode === "history" ? Units.gu(3) : Units.gu(5)
                        anchors.topMargin: dataMode === "history" ? Units.gu(1.5) : Units.gu(0.5)
                        anchors.leftMargin: Units.gu(1)
                        horizontalAlignment: Image.AlignLeft
                    }
                }

                Text {
                    id: dataUrlTitle
                    anchors.top: dataSectionRect.top
                    anchors.topMargin: Units.gu(0.75)
                    height: dataSectionRect.height
                    width:  dataMode === "history" ? parent.width - Units.gu(5) : dataMode === "bookmarks" ? parent.width - Units.gu(12.5) : parent.width - Units.gu(2)
                    anchors.left: dataResultsRect.right
                    anchors.leftMargin: Units.gu(0.5)
                    clip: true
                    horizontalAlignment: Text.AlignLeft
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("16pt")
                    color: "#494949"
                    elide: Text.ElideRight
                    text: model.title || ""
                    Text {
                        height: parent.height
                        width: parent.width
                        id: url
                        clip: true
                        anchors.top: dataUrlTitle.top
                        anchors.topMargin: Units.gu(0.75)
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: dataUrlTitle.left
                        font.family: "Prelude"
                        font.pixelSize: FontUtils.sizeToPixels("small")
                        text: model.url || ""
                        color: "#838383"
                        elide: Text.ElideRight
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            sidePanelRoot.hide();
                            goToURL(model.url);
                        }
                    }
                }
                Image {
                    id: dataResultsInfoImage
                    source: dataMode === "bookmarks" ? "images/bookmark-info-icon.png" : ""
                    anchors.top: dataSectionRect.top
                    anchors.right: dataSectionRect.right
                    height: Units.gu(3)
                    width: Units.gu(3)
                    anchors.topMargin: Units.gu(1.5)
                    anchors.rightMargin: Units.gu(1)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            editBookmark(model.url, model.title, model.icon64 ? model.icon64 : model.icon, model._id);
                        }
                    }
                }


                Rectangle {
                    color: "silver"
                    height: Units.gu(1 / 10)
                    width: parent.width
                    anchors.top: dataSectionRect.bottom
                }
            }
        }
    }


    Rectangle {
        id: sidePanelFooter
        height: Units.gu(5.2)
        width: parent.width
        color: "#343434"
        anchors.bottom: parent.bottom

        Image {
            id: dragHandle
            source: "images/drag-handle.png"
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: dragHandle
                onClicked: {
                    sidePanelRoot.visible = false

                }
            }
        }

        Image {
            id: addBookMark
            source: "images/menu-icon-add.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            height: Units.gu(4)
            width: Units.gu(4)
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: addBookmarkMouseArea.pressed ? Image.AlignBottom : Image.AlignTop
            visible: dataMode === "bookmarks"

            MouseArea {
                id: addBookmarkMouseArea
                anchors.fill: addBookMark
                enabled: webViewItem.url != ""
                onClicked: addBookmark();
            }
        }

        Rectangle {
            id: clearDownloads
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: sidePanelFooter.right
            anchors.rightMargin: Units.gu(2)
            height: Units.gu(3.5)
            width: Units.gu(6)
            radius: 4
            color: "transparent"
            border.width: 1
            border.color: "#2D2D2D"
            visible: dataMode === "downloads"

            Text {
                id: clearDownloadsText
                text: "Clear"
                color: "#E5E5E5"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }

            MouseArea {
                anchors.fill: clearDownloads
                onClicked: {
                    //TODO need to do proper handling once Download Manager is there
                    console.log("clearDownloads clicked, ")
                }
            }
        }
    }
}
