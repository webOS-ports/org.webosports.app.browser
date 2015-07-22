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

Item {
    anchors.fill: parent
    z: 2
    visible: false
    enabled: visible

    MouseArea {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: _sidePanel.left
        onPressed: {
            sidePanel.visible = false
            mouse.accepted = false
        }
    }

    Rectangle {
        id: _sidePanel
        height: parent.height
        width: Screen.width < 900 ? Screen.width : Units.gu(32)
        anchors.right: parent.right
        color: "#E5E5E5"

        MouseArea { anchors.fill: parent; }

        Rectangle {
            id: sidePanelHeader
            height: Units.gu(5.2)
            width: parent.width
            color: "#343434"
            anchors.top: parent.top
            anchors.left: parent.left
            visible: true
            z: 3
            Rectangle {
                id: buttonRow
                width: Screen.width < 900 ? parent.width : Units.gu(30)
                height: Units.gu(4)
                x: Units.gu(1)
                radius: 4
                color: "transparent"
                anchors.verticalCenter: parent.verticalCenter
                visible: true
                z:3

                Rectangle {
                    id: bookmarkButton
                    implicitWidth: Screen.width < 900 ? ((parent.width - Units.gu(2)) /3) : Units.gu(10)
                    implicitHeight: Units.gu(4)
                    anchors.left: buttonRow.left
                    color: "transparent"

                    Image {
                        id: bookmarkButtonImage
                        source: "images/radiobuttondarkleftpressed.png"
                        anchors.fill: parent
                        anchors.left: bookmarkButton.left
                        MouseArea {
                            anchors.fill: bookmarkButtonImage
                            onClicked: {
                                dataMode = "bookmarks"
                                window.__queryDB(
                                            "find",
                                            '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')
                                bookmarkButtonImage.source = "images/radiobuttondarkleftpressed.png"
                                bookmarkButtonImageInside.verticalAlignment = Image.AlignBottom
                                addBookMark.visible = true

                                historyButtonImage.source = "images/radiobuttondarkmiddle.png"
                                historyButtonImageInside.verticalAlignment = Image.AlignTop

                                downloadButtonImage.source = "images/radiobuttondarkright.png"
                                downloadButtonImageInside.verticalAlignment = Image.AlignTop
                                clearDownloads.visible = false
                            }
                        }

                        Image {
                            id: bookmarkButtonImageInside
                            source: "images/toaster-icon-bookmarks.png"
                            height: Units.gu(4)
                            width: Units.gu(4)
                            clip: true
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignBottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Rectangle {
                    id: historyButton
                    implicitWidth: Screen.width < 900 ? ((parent.width - Units.gu(2)) /3) : Units.gu(10)
                    implicitHeight: Units.gu(4)
                    anchors.left: bookmarkButton.right
                    color: "transparent"
                    Image {
                        id: historyButtonImage
                        anchors.fill: parent
                        source: "images/radiobuttondarkmiddle.png"
                        anchors.left: parent.left

                        MouseArea {
                            anchors.fill: historyButtonImage
                            onClicked: {
                                dataMode = "history"
                                window.__queryDB(
                                            "find",
                                            '{"query":{"from":"com.palm.browserhistory:1", "limit":50, "orderBy":"date"}}')
                                bookmarkButtonImage.source = "images/radiobuttondarkleft.png"
                                bookmarkButtonImageInside.verticalAlignment = Image.AlignTop

                                addBookMark.visible = false

                                historyButtonImage.source
                                        = "images/radiobuttondarkmiddlepressed.png"
                                historyButtonImageInside.verticalAlignment = Image.AlignBottom

                                downloadButtonImage.source = "images/radiobuttondarkright.png"
                                downloadButtonImageInside.verticalAlignment = Image.AlignTop
                                clearDownloads.visible = false
                            }
                        }

                        Image {
                            id: historyButtonImageInside
                            source: "images/toaster-icon-history.png"
                            height: Units.gu(4)
                            width: Units.gu(4)
                            clip: true
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignTop
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                Rectangle {
                    id: downloadButton
                    implicitWidth: Screen.width < 900 ? ((parent.width - Units.gu(2)) /3) : Units.gu(10)
                    implicitHeight: Units.gu(4)
                    anchors.left: historyButton.right
                    color: "transparent"

                    Image {
                        id: downloadButtonImage
                        source: "images/radiobuttondarkright.png"
                        anchors.fill: parent
                        anchors.left: parent.left

                        MouseArea {
                            anchors.fill: downloadButtonImage
                            onClicked: {
                                dataMode = "downloads"
                                //TODO Mocked some data for now until we have the DownloadManager ready
                                myDownloadsData = '{"results":[{"url":"", "title":"Downloads not implemented yet"}]}'

                                downloadButtonImage.source
                                        = "images/radiobuttondarkrightpressed.png"
                                downloadButtonImageInside.verticalAlignment = Image.AlignBottom

                                historyButtonImage.source = "images/radiobuttondarkmiddle.png"
                                historyButtonImageInside.verticalAlignment = Image.AlignTop

                                bookmarkButtonImage.source = "images/radiobuttondarkmiddle.png"
                                bookmarkButtonImageInside.verticalAlignment = Image.AlignTop
                                addBookMark.visible = false
                                clearDownloads.visible = true
                            }
                        }

                        Image {
                            id: downloadButtonImageInside
                            source: "images/toaster-icon-downloads.png"
                            height: Units.gu(4)
                            width: Units.gu(4)
                            clip: true
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignTop
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
            visible: true
            z:2

            ListView {
                anchors.top: sidePanelBody.top
                clip: true
                id: dataList
                width: parent.width
                height: parent.height
                JSONListModel {
                    id: dataModel
                    json: getJSONData()

                    query: "$.results[*]"

                    function getJSONData() {
                        if (dataMode === "bookmarks") {
                            return myBookMarkData
                        } else if (dataMode === "downloads") {
                            return myDownloadsData
                        } else if (dataMode === "history") {
                            return myHistoryData
                        }
                        else
                        {
                            return "'{}'"
                        }

                    }
                }

                model: dataModel.model

                delegate: Rectangle {
                                  id: dataSectionRect
                                  height: Units.gu(6)
                                  width: parent.width
                                  anchors.left: parent.left
                                  color: "transparent"

                                  Rectangle {
                                      id: dataResultsRect
                                      height: Units.gu(6)
                                      anchors.left: dataSectionRect.left
                                      anchors.top: parent.top
                                      color: "transparent"
                                      width: dataMode === "history" ? Units.gu(4) : dataMode === "bookmarks" ? Units.gu(6) : Units.gu(1)

                                      Image {
                                          id: dataResultsImage
                                          source: dataMode === "history" ? "images/header-icon-history.png" : dataMode === "bookmarks" ? model.icon64 : ""
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
                                      font.pixelSize: FontUtils.sizeToPixels("large")
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
                                              sidePanel.visible = false
                                              webViewItem.url = model.url
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
                                              dimBackground.visible = true
                                              bookmarkDialog.action = "editBookmark"
                                              bookmarkDialog.myURL = model.url
                                              bookmarkDialog.myTitle = model.title
                                              bookmarkDialog.myBookMarkIcon = model.icon64 ? model.icon64 : model.icon
                                              bookmarkDialog.myBookMarkId = model._id
                                              bookmarkDialog.visible = true
                                              bookmarkDialog.myButtonText = "Save"
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
            visible: true
            z: 3

            Image {
                id: dragHandle
                source: "images/drag-handle.png"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: dragHandle
                    onClicked: {
                        sidePanel.visible = false

                    }
                }
            }

            Image {
                id: addBookMark
                source: "images/menu-icon-add.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                clip: true
                height: Units.gu(4)
                width: Units.gu(4)
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignTop
                visible: true

                MouseArea {
                    anchors.fill: addBookMark
                    onClicked: {
                        addBookMark.verticalAlignment = Image.AlignBottom


                        if (webViewItem.url != "") {
                            dimBackground.visible = true
                            bookmarkDialog.action = "addBookmark"
                            bookmarkDialog.myURL = "" + webViewItem.url
                            bookmarkDialog.myTitle = webViewItem.title
                            bookmarkDialog.myButtonText = "Add Bookmark"
                            bookmarkDialog.visible = true
                            sidePanel.visible = false
                        }
                    }
                    onReleased: {
                        addBookMark.verticalAlignment = Image.AlignTop
                    }
                    onExited: {
                        addBookMark.verticalAlignment = Image.AlignTop
                    }
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
                visible: false

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

        //Add a timer for our progress bar
        Timer {
            running: true
            repeat: true
            interval: 10
            onTriggered: {
                //disable the background, otherwise it won't show the page
                if (pageIsLoading) {
                    progressBar.progressBarColor = "#2E8CF7"
                    webViewItem.webViewBackgroundSource = ""
                    webViewItem.webViewPlaceholderSource = ""
                }
                //Update ProgressBar (this one is more accurate compared to legacy :))
                progressBar.value = webViewItem.loadProgress
            }
        }
    }
}
