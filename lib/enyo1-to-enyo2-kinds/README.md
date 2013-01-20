## Enyo 1 to Enyo 2 kinds
### What is this?!?
This is a README file, what else would it be? Oh, you meant the repo? Well, in that case, this repo is the place where I'm storing my replacement kinds for Enyo 1 functionality that doesn't exist in Enyo 2. Things like the ModalDialog, for example.
### What exactly does it currently include/do?
Right now there are four replacement kinds here (AppMenu, ModalDialog, and HtmlContent, WebView). In addition to this, I've also got a replacement enyo.fetchAppInfo() method in there. There may be more replacement kinds added as time goes on.
### Well, how do I use it?
It's simple, really. All you've got to do is a very simple terminal or command line command with git (or use a GUI Git client, but don't expect me to support you there):
`git clone https://github.com/ArthurThornton/enyo1-to-enyo2-kinds.git`
Make sure you run that command in your app's root directory (or wherever your root package.js file is). Then just add a line to your package.js file pointing to the directory and all will be golden. No, really, it'll turn to gold!
### What is the license for this code?
I chose to license my kinds in the same way the Enyo team licenses Enyo, primarily for simplicity, but also because I just felt if I'm building code for Enyo developers I might as well license it the same way the Enyo team licenses Enyo. That means this code is released under the Apache 2.0 license. You can see the license in full text in the LICENSE-2.0.txt file.