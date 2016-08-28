import QtQuick 2.0

import LuneOS.Service 1.0

Db8Model {
    id: historyDbModel
    kind: "com.palm.browserhistory:1"
    watch: true
    query: { "limit":50, "orderBy":"date" }

    function addHistoryUrl(url, title, avoidDuplicates) {
        if(avoidDuplicates) {
            __queryDB("del",
                      '{"query":{"from":"com.palm.browserhistory:1", "where":[{"prop":"url", "op":"=", "val":"' + url + '"}]}}')
        }

        var history = {
            _kind: "com.palm.browserhistory:1",
            url: "" + url,
            title: "" + title,
            date: (new Date()).getTime()
        }

        __queryDB("put", JSON.stringify({objects: [history]}));
    }

    function clearDB() {
        __queryDB("del", '{"query":{"from":"com.palm.browserhistory:1"}}');
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
