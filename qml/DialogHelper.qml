import QtQuick 2.0

Rectangle {
    // the purpose of this item is simply to catch mouse clicks outside of the
    // eventually currently shown dialog/panel.
    id: dialogBackground
    visible: false
    color: "#4C4C4C"
    opacity: 0.8

    property Item currentShowDialog

    signal dialogHidden();

    MouseArea {
        anchors.fill: parent
        onClicked: hideCurrentDialog();
    }

    function showDialog(dialog, opacityBg) {
        if(currentShowDialog)
            currentShowDialog.hide();

        currentShowDialog = dialog;
        dialogBackground.opacity = opacityBg;

        if(currentShowDialog)
            currentShowDialog.show();

        dialogBackground.visible = true;
    }

    function hideCurrentDialog() {
        if(currentShowDialog)
            currentShowDialog.hide();
        currentShowDialog = null;
        dialogBackground.visible = false;

        dialogHidden();
    }

    Connections {
        target: currentShowDialog
        onVisibleChanged: {
            if(currentShowDialog && !currentShowDialog.visible) {
                hideCurrentDialog();
            }
        }
    }
}
