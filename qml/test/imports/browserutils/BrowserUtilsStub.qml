import QtQuick 2.0

QtObject {
	property Item webview
	signal webViewSaved(variant success, variant fileName)
	signal iconGenerated(variant success, variant fileName)
	function generateIconFromFile(inFile, outFile, imageSize) {iconGenerated(true, "images/launcher-bookmark-overlay.png")}
	function saveViewToFile(outFile, imageSize) {webViewSaved(true, "images/launcher-bookmark-overlay.png")}
}
