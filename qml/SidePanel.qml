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

import QtQuick 2.6

import QtQuick.Controls 2.0
import QtQuick.Controls.LuneOS 2.0

import LunaNext.Common 0.1
import LuneOS.Service 1.0

import "Models"

Drawer {
    id: sidePanelRoot

    signal goToURL(string url);
    signal addBookmark();
    signal editBookmark(string url, string title, string icon, string id);

    property BookmarkDbModel  bookmarksDbModel
    property HistoryDbModel   historyDbModel
    property DownloadsDbModel downloadsDbModel

    property alias modeIndex: tabBar.currentIndex
    property string dataMode: modeIndex===0 ? "bookmarks" : modeIndex === 1 ? "history" : "downloads"

    Page {
        anchors.fill: parent

        header: TabBar {
            id: tabBar
            height: Units.gu(4)
            currentIndex: 0

            TabButton {
                height: parent.height
                LuneOSButton.image: Qt.resolvedUrl("images/toaster-icon-bookmarks.png")
            }
            TabButton {
                height: parent.height
                LuneOSButton.image: Qt.resolvedUrl("images/toaster-icon-history.png")
            }
            TabButton {
                height: parent.height
                LuneOSButton.image: Qt.resolvedUrl("images/toaster-icon-downloads.png")
            }
        }

        ListView {
            anchors.fill: parent
            clip: true
            id: dataList

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
                            sidePanelRoot.close();
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

        footer: ToolBar {
            id: handleToolbar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Units.gu(5.2)

            Image {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                source: Qt.resolvedUrl("images/drag-handle.png")
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
                    anchors.fill: parent
                    enabled: webViewItem.url != ""
                    onClicked: addBookmark();
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Units.gu(2)
                height: Units.gu(3.5)
                width: Units.gu(6)
                radius: 4
                color: "transparent"
                border.width: 1
                border.color: "#2D2D2D"
                visible: dataMode === "downloads"

                Text {
                    text: "Clear"
                    color: "#E5E5E5"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        //TODO need to do proper handling once Download Manager is there
                        console.log("clearDownloads clicked, ")
                    }
                }
            }
        }
    }
}
