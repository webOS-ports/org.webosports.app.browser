/*
* Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
* Copyright (C) 2014 Herman van Hazendonk <github.com@herrie.org>
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
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import LuneOS.Service 1.0
import LunaNext.Common 0.1

import "js/util.js" as EnyoUtils

Rectangle {
    id: seachSuggestionsItem
    property string searchString

    signal suggestionsCountChanged(int count);
    signal requestUrl(string url);

    property string optSearchText: ""
    property string defaultSearchIcon: ""

    color: "#DADADA"
    radius: 4
    visible: false
    height: (urlModel.count + 1) * Units.gu(6)

    function show() {
        visible = true;
    }
    function hide() {
        visible = false;
    }

    onSearchStringChanged: {
        urlModel.clear();

        if (searchString.length === 0 ||
            searchString.substring(0, 4) === "http" ||
            searchString.substring(0, 3) === "ftp" ||
            searchString.substring(0, 4) === "data" ||
            searchString.substring(0, 4) === "file")
        {
            seachSuggestionsItem.hide();
        }
        else
        {
            seachSuggestionsItem.__queryBookmarks(searchString);
        }
    }

    ListModel {
        id: urlModel

        onCountChanged: suggestionsCountChanged(count);
    }

    ListView {
        id: suggestionList
        anchors.fill: parent
        clip: true

        model: urlModel

        header: Item {
            height: Units.gu(6)
            width: suggestionList.width

            Text {
                id: optSearch
                text: seachSuggestionsItem.optSearchText + " \"" + addressBarItem.addressBarText + "\""
                anchors.fill: parent
                anchors.leftMargin: Units.gu(2)
                anchors.rightMargin: Units.gu(5)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: FontUtils.sizeToPixels("large")
                font.family: "Prelude"
                color: "#494949"
                height: Units.gu(6)
                elide: Text.ElideRight

                Image {
                    id: imgSearch
                    height: Units.gu(3)
                    width: Units.gu(3)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.right
                    anchors.leftMargin: Units.gu(1.5)
                    horizontalAlignment: Image.AlignRight
                    source: seachSuggestionsItem.defaultSearchIcon
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    seachSuggestionsItem.hide();
                    requestUrl(defaultSearchURL.replace("#{searchTerms}", addressBarItem.addressBarText));
                }
            }
            Rectangle {
                id: searchDivider
                color: "silver"

                width: parent.width
                height: urlModel.count > 0 ? Units.gu(1 / 5) : 0
                anchors.top: optSearch.bottom
            }
        }
        delegate: Item {
            id: sectionRect
            height: Units.gu(6)
            width: suggestionList.width

            Text {
                id: urlTitle
                anchors.top: sectionRect.top
                anchors.topMargin: Units.gu(0.75)
                height: sectionRect.height
                clip: true
                width: sectionRect.width - Units.gu(7)
                anchors.left: sectionRect.left
                anchors.leftMargin: Units.gu(2)
                horizontalAlignment: Text.AlignLeft
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("large")
                color: "#494949"
                textFormat: Text.RichText
                text: EnyoUtils.applyFilterHighlight(model.title,
                                                     addressBarItem.addressBarText)
                Text {
                    height: parent.height
                    clip: true
                    id: url
                    width: parent.width
                    anchors.top: urlTitle.top
                    anchors.topMargin: Units.gu(0.75)
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left
                    horizontalAlignment: Text.AlignLeft
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("small")
                    textFormat: Text.RichText
                    text: EnyoUtils.applyFilterHighlight(model.url,
                                                         addressBarItem.addressBarText)
                    color: "#838383"
                }
            }
            Rectangle {
                color: "silver"
                height: Units.gu(1 / 10)
                width: parent.width
                anchors.top: parent.top
            }

            Rectangle {
                id: imgResultsRect
                height: Units.gu(6)
                anchors.right: parent.right
                anchors.top: sectionRect.top

                Image {
                    source: model.icon64 ? model.icon64: model.icon
                    anchors.top: imgResultsRect.top
                    anchors.right: parent.right
                    height: Units.gu(3)
                    width: Units.gu(3)
                    anchors.topMargin: Units.gu(1.5)
                    anchors.rightMargin: Units.gu(1)
                    horizontalAlignment: Image.AlignRight
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    seachSuggestionsItem.hide();
                    requestUrl(model.url);
                }
            }
        }
    }

    /////// private //////
    LunaService {
        id: luna
        name: "org.webosports.app.browser"
    }

    function __queryBookmarks(inputSearchString) {
        luna.call("luna://com.palm.db/search",
                  '{"query":{"from":"com.palm.browserbookmarks:1", "where":[{"prop":"searchText", "op":"?", "val":'
                  + "\"" + inputSearchString + "\""
                  + ', "collate":"primary"}], "orderBy": "_rev", "desc": true}}',
                  __handleQueryBookmarksDBSuccess, __handleQueryBookmarksDBError)
    }

    function __handleQueryBookmarksDBError(message) {
        console.warn("Could not query bookmarks DB : " + message)
    }

    function __handleQueryBookmarksDBSuccess(message) {
        // put all these results in the model
        var searchResultsBookmarks = JSON.parse(message.payload)
        for (var j = 0, t; t = searchResultsBookmarks.results[j]; j++) {
            urlModel.append({
                               url: t.url,
                               title: t.title,
                               icon64: t.icon64,
                               icon: "images/header-icon-bookmarks.png"
                           })
        }

        luna.call("luna://com.palm.db/search",
                  '{"query":{"from":"com.palm.browserhistory:1", "where":[{"prop":"searchText", "op":"?", "val":'
                  + "\"" + addressBarItem.addressBarText + "\""
                  + ', "collate":"primary"}], "orderBy": "_rev", "desc": true}}',
                  __handleQueryHistoryDBSuccess, __handleQueryHistoryDBError)
    }

    function __handleQueryHistoryDBError(message) {
        console.warn("Could not query History DB : " + message)
    }

    function __handleQueryHistoryDBSuccess(message) {
        // put all these results in the model
        var searchResultsHistory = JSON.parse(message.payload)
        if (searchResultsHistory.results.length <= 32) {
            for (var i = 0, s; s = searchResultsHistory.results[i]; i++) {
                urlModel.append({
                                   url: s.url,
                                   title: s.title,
                                   icon64: s.icon64,
                                   icon: "images/header-icon-history.png"
                               })
            }
        }
    }
}
