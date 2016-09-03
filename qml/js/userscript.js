
var _channelAPI = {};

var _channel = new QWebChannel(qt.webChannelTransport, function(channel) {
    // all published objects are available in channel.objects under
    // the identifier set in their attached WebChannel.id property
    _channelAPI = channel.objects;
});

function postMessage(message) {
    var messageHelper = _channelAPI.messageHelper;
    messageHelper.onMessageReceived(message, function(ret) {});
}

var frames = document.documentElement.getElementsByTagName('iframe');

function getImgFullUri(uri) {
    if ((uri.slice(0, 7) === 'http://') ||
        (uri.slice(0, 8) === 'https://') ||
        (uri.slice(0, 7) === 'file://')) {
        return uri;
    } else if (uri.slice(0, 1) === '/') {
        var docuri = document.documentURI;
        var firstcolon = docuri.indexOf('://');
        var protocol = 'http://';
        if (firstcolon !== -1) {
            protocol = docuri.slice(0, firstcolon + 3);
        }
        return protocol + document.domain + uri;
    } else {
        var base = document.baseURI;
        var lastslash = base.lastIndexOf('/');
        if (lastslash === -1) {
            return base + '/' + uri;
        } else {
            return base.slice(0, lastslash + 1) + uri;
        }
    }
}

function elementContainedInBox(element, box) {
    var rect = element.getBoundingClientRect();
    return ((box.left <= rect.left) && (box.right >= rect.right) &&
            (box.top <= rect.top) && (box.bottom >= rect.bottom));
}

function getSelectedData(element) {
    var node = element;
    var data = new Object;

    var nodeName = node.nodeName.toLowerCase();
    if (nodeName === 'img') {
        data.img = getImgFullUri(node.getAttribute('src'));
    } else if (nodeName === 'a') {
        data.href = node.href;
        data.title = node.title;
    }

    // If the parent tag is a hyperlink, we want it too.
    var parent = node.parentNode;
    if ((nodeName !== 'a') && parent && (parent.nodeName.toLowerCase() === 'a')) {
        data.href = parent.href;
        data.title = parent.title;
        node = parent;
    }

    return data;
}

function adjustSelection(selection) {
    // FIXME: allow selecting two consecutive blocks, instead of
    // interpolating to the containing block.

    var data = new Object;

    //console.debug("[userscript.js] Jumped into adjustSelection")

    var centerX = (selection.left + selection.right) / 2;
    var centerY = (selection.top + selection.bottom) / 2;
    var element = document.elementFromPoint(centerX, centerY);
    var parent = element;
    while (elementContainedInBox(parent, selection)) {
        parent = parent.parentNode;
    }
    element = parent;

    node = element.cloneNode(true);
    // filter out script nodes
    var scripts = node.getElementsByTagName('script');
    while (scripts.length > 0) {
        var scriptNode = scripts[0];
        if (scriptNode.parentNode) {
            scriptNode.parentNode.removeChild(scriptNode);
        }
    }
    data.html = node.outerHTML;
    data.nodeName = node.nodeName.toLowerCase();
    // FIXME: extract the text and images in the order they appear in the block,
    // so that this order is respected when the data is pushed to the clipboard.
    data.text = node.textContent;
    var images = [];
    var imgs = node.getElementsByTagName('img');
    for (var i = 0; i < imgs.length; i++) {
        images.push(getImgFullUri(imgs[i].getAttribute('src')));
    }
    if (images.length > 0) {
        data.images = images;
    }

    return data
}

function checkNode(e, node) {
    // hook for Open in New Tab (link with target)
    if (node.tagName === 'A') {
        var link = new Object({'type':'link', 'pageX': e.pageX, 'pageY': e.pageY})
        if (node.hasAttribute('target'))
            link.target = node.getAttribute('target');
        link.href = node.href //node.getAttribute('href'); // We want always the absolute link
        postMessage( JSON.stringify(link) );
    }
}

// Catch window open events as normal links
window.open = function (url, windowName, windowFeatures) {
    var link = new Object({'type':'link', 'target':'_blank', 'href':url});
    postMessage( JSON.stringify(link) );
}

// virtual keyboard hook
window.document.addEventListener('click', (function(e) {
    if (e.srcElement.tagName === ('INPUT'||'TEXTAREA')) {
        var inputContext = new Object({'type':'input', 'state':'show'})
        postMessage(JSON.stringify(inputContext))
    }
}), true);
window.document.addEventListener('focus', (function(e) {
    if (e.srcElement.tagName === ('INPUT'||'TEXTAREA')) {
        var inputContext = new Object({'type':'input', 'state':'show'})
        postMessage(JSON.stringify(inputContext))
    }
}), true);
//window.document.addEventListener('blur', (function() {
//    var inputContext = new Object({'type':'input', 'state':'hide'})
//    postMessage(JSON.stringify(inputContext))
//}), true);

document.documentElement.addEventListener('click', (function(e) {
    var node = e.target;
    while(node) {
        checkNode(e, node);
        node = node.parentNode;
    }
}), true);

//FIXME
//Disabled window.onload for now because we don't use it and it seems to break some websites like
//https://www.abnamro.nl/portalserver/nl/prive/index.html?l

/*window.onload = function() {
    var inputs = document.getElementsByTagName('INPUT');
    var textareas = document.getElementsByTagName('TEXTAREA');

    for(var i = 0; i < inputs.length; i++) {
        var elem = inputs[i];

        if(elem.type == 'text' || elem.type == 'password') {
            elem.onfocus = function() {
                var inputContext = new Object({'type':'input', 'state':'show'})
                postMessage(JSON.stringify(inputContext))
            }
            elem.onblur = function() {
                var inputContext = new Object({'type':'input', 'state':'hide'})
                postMessage(JSON.stringify(inputContext))
            }
        }
    }

    for(var j = 0; j < textareas.length; j++) {
        var telem = textareas[j];

        telem.onfocus = function() {
            var inputContext = new Object({'type':'input', 'state':'show'})
            postMessage(JSON.stringify(inputContext))
        }
        telem.onblur = function() {
            var inputContext = new Object({'type':'input', 'state':'hide'})
            postMessage(JSON.stringify(inputContext))
        }
    }
}

navigator.qt.onmessage = function(ev) {
    //console.debug("[userscript.js] message received")
    var data = JSON.parse(ev.data)
    if (data.type === 'readability') {

        readStyle='style-novel';
        readSize='size-large';
        readMargin='margin-wide';

        _readability_script = document.createElement('SCRIPT');
        _readability_script.type = 'text/javascript';
        _readability_script.text = data.content;
        document.getElementsByTagName('head')[0].appendChild(_readability_script);
    }
    else if (data.type === 'adjustselection') {
        //console.debug("[userscript.js] 'query' received")
        var selection = adjustSelection(data);
        selection.type = 'selectionadjusted';
        postMessage(JSON.stringify(selection));

    }
    else if (data.type === "search") {
        findString(data.searchTerm)
    }
}
*/

