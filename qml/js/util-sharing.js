//   Copyright 2012 Hewlett-Packard Development Company, L.P.
//   Copyright 2014 Herman van Hazendonk (github.com@herrie.org)
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

function shareLinkViaMessaging (url)
{
    var params = {
        compose: {
            messageText: $L("Check out this web page: ") + url
        }
    };
    navigationBar.__launchApplication("com.palm.app.messaging", params);
};

function shareLinkViaEmail(inUrl, inTitle)
{
    var msg = "Here's a website I think you'll like: <a href=\"" + inUrl + "\">" + (inTitle || inUrl) + "</a>"

    var params = {
        summary: ("Check out this web page..."),
        text: msg
        }
    navigationBar.__launchApplication("com.palm.app.email", params)
};

function shareLinkViaMessaging (inUrl, inTitle) {
   var params = {
       compose: {
           messageText: "Check out this web page: " + inUrl
       }
   };
    navigationBar.__launchApplication("org.webosports.messaging", params)
};


