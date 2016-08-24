import QtQuick 2.0

Item {
    visible: false

    function copyToClipboard(inputText)
    {
        __hackClipboard.text = inputText;
        __hackClipboard.selectAll();
        __hackClipboard.cut();
    }

    TextInput {
        id: __hackClipboard
    }
}
