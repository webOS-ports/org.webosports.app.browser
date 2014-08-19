import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1
import "js/util.js" as URLUtil

Rectangle {
    id: navigationBar

    property Item webView: null

    width: parent.width
    height: Units.gu(5.2)
    color: "gray"

    Image {
        id: backImage
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-back.png"
        height: 32
        width: 32
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: .5
    }

    Image {
        id: forwardImage
        anchors.left: backImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-forward.png"
        height: 32
        width: 32
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: .5
    }


    TextField {
        id: addressBar
        anchors.left: forwardImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        width: navigationBar.width - forwardImage.width - backImage.width -shareImage.width - newCardImage.width - bookmarkImage.width - 20
        height: Units.gu(3)
        style: TextFieldStyle {
                //textColor: "#e5e5e5"
                background: Rectangle {
                    radius: 3
                    implicitWidth: addressBar.width
                    implicitHeight: addressBar.height
                    //border.color: "#333"
                    border.width: 1
                }
            }
        // anchors.fill: parent


        /*Image {
            id: secureSite
            anchors.verticalCenter: addressBar.verticalCenter
            source: "images/secure-lock.png" & webView.url
        }*/

        Image {
            id: faviconImage
            anchors.verticalCenter: addressBar.verticalCenter
            source: webView.icon
        }

        Image {
            id: stopImage
            anchors.right: addressBar.right
            anchors.verticalCenter: addressBar.verticalCenter
            source: "images/menu-icon-stop.png"
            height: 24
            width: 24
            clip: true
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignTop
        }

        font.pixelSize: FontUtils.sizeToPixels("Medium")
        font.family: "Prelude"

        anchors.margins: Units.gu(1)
        focus: true
        //text: webView && webView.url
        //text: webView.url
        placeholderText: "Enter URL or search terms"

        onAccepted: updateURL()

        //TODO Dirty function for prefixing with http:// for now. Needs to be replaced by proper solution for example: https://github.com/isis-project/isis-browser/blob/master/source/util.js
        function updateURL() {
            var uri = URLUtil.parseUri(addressBar.text)
            if ((URLUtil.isValidScheme(uri) && URLUtil.isUri(addressBar.text, uri)) || (enyo.windowParams.allowAllSchemes && uri.scheme)) {
                if(text.substring(0,7)==="http://" || text.substring(0,8)==="https://")
                {
                    webView.url = addressBar.text;
                }
                else
                {
                    webView.url = "http://" + addressBar.text;
                    addressBar.text = "http://" + addressBar.text;
                }
            }
            else {
                //TODO URL handling for "invalid URI's"
                console.log("invalid URL")
            }
        }
    }

    Image {
        id: shareImage
        anchors.left: addressBar.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-share.png"
        height: 32
        width: 32
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: .5
    }

    Image {
        id: newCardImage
        anchors.left: shareImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-newcard.png"
        height: 32
        width: 32
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: .5
    }

    Image {
        id: bookmarkImage
        anchors.left: newCardImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-bookmark.png"
        height: 32
        width: 32
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: .5
    }

}
