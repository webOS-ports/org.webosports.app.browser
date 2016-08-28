import QtQuick 2.0

import LuneOS.Service 1.0

ListModel {
    //TODO Mocked some data for now until we have the DownloadManager ready
    id: downloadsDbModel
    Component.onCompleted: downloadsDbModel.append({"url":"", "title":"Downloads not implemented yet"});
}

