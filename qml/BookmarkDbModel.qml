import QtQuick 2.0

import LuneOS.Service 1.0

Db8Model {
    id: bookmarksDbModel
    kind: "com.palm.browserbookmarks:1"
    watch: true
    query: { "limit":32 }

    function editBookmark (inTitle, inUrl, inIcons, inId) {
        var date = (new Date()).getTime();
        var b = {
            _kind: "com.palm.browserbookmarks:1",
            _id: inId,
            title: inTitle,
            url: inUrl,
            date: date,
            icon64: inIcons
        };
        //mixin(b, inIcons);
        __queryDB("merge", JSON.stringify({objects: [b]}));
    }

    function addBookmark(inTitle, inUrl, inIcons) {
        var date = (new Date()).getTime();
        var b = {
            _kind: "com.palm.browserbookmarks:1",
            title: inTitle,
            url: inUrl,
            date: date,
            lastVisited: date,
            defaultEntry: false,
            visitCount: 0,
            icon64: inIcons,
            idx: null
        };
        //mixin(b, inIcons);
         __queryDB("put", b)
        //this.$.bookmarksService.call({objects: [b]}, {method: "put"});
    }

    property QtObject __ls2service: LunaService {
        name: "org.webosports.app.browser"
    }
    function __queryDB(action, params) {
        __ls2service.call("luna://com.palm.db/" + action, params,
                  __handleQueryDBSuccess, __handleQueryDBError);
    }
    function __handleQueryDBSuccess(message) {
        console.log("Handle DB Query Success: "+JSON.stringify(message.payload));
    }
    function __handleQueryDBError(message) {
        console.log("Could not query DB : " + message);
    }
}
