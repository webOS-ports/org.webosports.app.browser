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

    function get_host(url){
        return String(url).replace(/^((\w+:)?\/\/[^\/]+\/?).*$/,'$1');
    }

	function applyFilterHighlight(a, b) {
	//function applyFilterHighlight(a, b, c) {
        //return a.replace(new RegExp(b, "i"), '<span class="' + c + '">$&</span>');
    //We cannot use classes and background images so we use color and underline here instead
    //console.log("log output: "+a.replace(new RegExp(b, "i"), '<span style="color:#5B8DB8; text-decoration: underline;">$&</span>'))
        if(a)
        {
            if(a.length>0)
            {
                return a.replace(new RegExp(b, "i"), '<span style="color:#5B8DB8; text-decoration: underline;">$&</span>');
            }
            else
            {
                return "";
            }
        }
        else
        {
            return "";
        }

	}

	function parseUri (inText) {
		var keys = ["source","scheme","authority","userinfo","host","tld","port","path","query","fragment"];
		var re = /^(?:([^:\/\?#@\d]+):)?(?:\/\/)?((?:([^\/\?#]*)@)?([^\/\?#:]*\.([^\/\?#:]*))(?::(\d*))?)?([^\?#]*)(?:\\\?([^#]*))?(?:#(.*))?/;
		var a = re.exec(inText);
		var parsed = {};
		for (var i=0; i<keys.length; i++) {
			parsed[keys[i]] = a[i];
		}
		return parsed;
	}
	
	function isValidUri (inUri) {

        // consider valid if user specified a scheme
		if (inUri.scheme) {
			return true;
		}
		// consider inHost valid if the host looks like an IP
		if (inUri.host) {
			var re = /^((?:\d){1,3})\.((?:\d){1,3})\.((?:\d){1,3})\.((?:\d){1,3})$/;
			var a = re.exec(inUri.host);
			if (a && a[1] < 256 && a[2] < 256 && a[3] < 256 && a[4] < 256) {
				return true;
			}
		}
		// consider inHost valid if its suffix is a valid TLD
        var tld = [
                    "ac",
                    "academy",
                    "accountants",
                    "active",
                    "actor",
                    "ad",
                    "ae",
                    "aero",
                    "af",
                    "ag",
                    "agency",
                    "ai",
                    "airforce",
                    "al",
                    "am",
                    "an",
                    "ao",
                    "aq",
                    "ar",
                    "archi",
                    "army",
                    "arpa",
                    "as",
                    "asia",
                    "associates",
                    "at",
                    "attorney",
                    "au",
                    "auction",
                    "audio",
                    "autos",
                    "aw",
                    "ax",
                    "axa",
                    "az",
                    "ba",
                    "bar",
                    "bargains",
                    "bayern",
                    "bb",
                    "bd",
                    "be",
                    "beer",
                    "berlin",
                    "best",
                    "bf",
                    "bg",
                    "bh",
                    "bi",
                    "bid",
                    "bike",
                    "bio",
                    "biz",
                    "bj",
                    "black",
                    "blackfriday",
                    "blue",
                    "bm",
                    "bmw",
                    "bn",
                    "bnpparibas",
                    "bo",
                    "boutique",
                    "br",
                    "brussels",
                    "bs",
                    "bt",
                    "build",
                    "builders",
                    "buzz",
                    "bv",
                    "bw",
                    "by",
                    "bz",
                    "bzh",
                    "ca",
                    "cab",
                    "camera",
                    "camp",
                    "cancerresearch",
                    "capetown",
                    "capital",
                    "caravan",
                    "cards",
                    "care",
                    "career",
                    "careers",
                    "cash",
                    "cat",
                    "catering",
                    "cc",
                    "cd",
                    "center",
                    "ceo",
                    "cern",
                    "cf",
                    "cg",
                    "ch",
                    "cheap",
                    "christmas",
                    "church",
                    "ci",
                    "citic",
                    "city",
                    "ck",
                    "cl",
                    "claims",
                    "cleaning",
                    "click",
                    "clinic",
                    "clothing",
                    "club",
                    "cm",
                    "cn",
                    "co",
                    "codes",
                    "coffee",
                    "college",
                    "cologne",
                    "com",
                    "community",
                    "company",
                    "computer",
                    "condos",
                    "construction",
                    "consulting",
                    "contractors",
                    "cooking",
                    "cool",
                    "coop",
                    "country",
                    "cr",
                    "credit",
                    "creditcard",
                    "cruises",
                    "cu",
                    "cuisinella",
                    "cv",
                    "cw",
                    "cx",
                    "cy",
                    "cymru",
                    "cz",
                    "dance",
                    "dating",
                    "de",
                    "deals",
                    "degree",
                    "democrat",
                    "dental",
                    "dentist",
                    "desi",
                    "diamonds",
                    "diet",
                    "digital",
                    "direct",
                    "directory",
                    "discount",
                    "dj",
                    "dk",
                    "dm",
                    "dnp",
                    "do",
                    "domains",
                    "durban",
                    "dz",
                    "ec",
                    "edu",
                    "education",
                    "ee",
                    "eg",
                    "email",
                    "engineer",
                    "engineering",
                    "enterprises",
                    "equipment",
                    "er",
                    "es",
                    "estate",
                    "et",
                    "eu",
                    "eus",
                    "events",
                    "exchange",
                    "expert",
                    "exposed",
                    "fail",
                    "farm",
                    "feedback",
                    "fi",
                    "finance",
                    "financial",
                    "fish",
                    "fishing",
                    "fitness",
                    "fj",
                    "fk",
                    "flights",
                    "florist",
                    "fm",
                    "fo",
                    "foo",
                    "foundation",
                    "fr",
                    "frogans",
                    "fund",
                    "furniture",
                    "futbol",
                    "ga",
                    "gal",
                    "gallery",
                    "gb",
                    "gd",
                    "ge",
                    "gent",
                    "gf",
                    "gg",
                    "gh",
                    "gi",
                    "gift",
                    "gifts",
                    "gives",
                    "gl",
                    "glass",
                    "global",
                    "globo",
                    "gm",
                    "gmo",
                    "gn",
                    "gop",
                    "gov",
                    "gp",
                    "gq",
                    "gr",
                    "graphics",
                    "gratis",
                    "green",
                    "gripe",
                    "gs",
                    "gt",
                    "gu",
                    "guide",
                    "guitars",
                    "guru",
                    "gw",
                    "gy",
                    "hamburg",
                    "haus",
                    "healthcare",
                    "help",
                    "hiphop",
                    "hiv",
                    "hk",
                    "hm",
                    "hn",
                    "holdings",
                    "holiday",
                    "homes",
                    "horse",
                    "host",
                    "hosting",
                    "house",
                    "how",
                    "hr",
                    "ht",
                    "hu",
                    "id",
                    "ie",
                    "il",
                    "im",
                    "immobilien",
                    "in",
                    "industries",
                    "info",
                    "ink",
                    "institute",
                    "insure",
                    "int",
                    "international",
                    "investments",
                    "io",
                    "iq",
                    "ir",
                    "is",
                    "it",
                    "je",
                    "jetzt",
                    "jm",
                    "jo",
                    "jobs",
                    "joburg",
                    "jp",
                    "juegos",
                    "kaufen",
                    "ke",
                    "kg",
                    "kh",
                    "ki",
                    "kim",
                    "kitchen",
                    "kiwi",
                    "km",
                    "kn",
                    "koeln",
                    "kp",
                    "kr",
                    "krd",
                    "kred",
                    "kw",
                    "ky",
                    "kz",
                    "la",
                    "lacaixa",
                    "land",
                    "lawyer",
                    "lb",
                    "lc",
                    "lease",
                    "lgbt",
                    "li",
                    "life",
                    "lighting",
                    "limited",
                    "limo",
                    "link",
                    "lk",
                    "loans",
                    "london",
                    "lotto",
                    "lr",
                    "ls",
                    "lt",
                    "ltda",
                    "lu",
                    "luxe",
                    "luxury",
                    "lv",
                    "ly",
                    "ma",
                    "maison",
                    "management",
                    "mango",
                    "market",
                    "marketing",
                    "mc",
                    "md",
                    "me",
                    "media",
                    "meet",
                    "melbourne",
                    "menu",
                    "mg",
                    "mh",
                    "miami",
                    "mil",
                    "mini",
                    "mk",
                    "ml",
                    "mm",
                    "mn",
                    "mo",
                    "mobi",
                    "moda",
                    "moe",
                    "monash",
                    "mortgage",
                    "moscow",
                    "motorcycles",
                    "mp",
                    "mq",
                    "mr",
                    "ms",
                    "mt",
                    "mu",
                    "museum",
                    "mv",
                    "mw",
                    "mx",
                    "my",
                    "mz",
                    "na",
                    "nagoya",
                    "name",
                    "navy",
                    "nc",
                    "ne",
                    "net",
                    "neustar",
                    "nf",
                    "ng",
                    "ngo",
                    "nhk",
                    "ni",
                    "ninja",
                    "nl",
                    "no",
                    "np",
                    "nr",
                    "nra",
                    "nrw",
                    "nu",
                    "nyc",
                    "nz",
                    "okinawa",
                    "om",
                    "ong",
                    "onl",
                    "ooo",
                    "org",
                    "organic",
                    "ovh",
                    "pa",
                    "paris",
                    "partners",
                    "parts",
                    "pe",
                    "pf",
                    "pg",
                    "ph",
                    "photo",
                    "photography",
                    "photos",
                    "physio",
                    "pics",
                    "pictures",
                    "pink",
                    "pk",
                    "pl",
                    "place",
                    "plumbing",
                    "pm",
                    "pn",
                    "post",
                    "pr",
                    "praxi",
                    "press",
                    "pro",
                    "productions",
                    "properties",
                    "property",
                    "ps",
                    "pt",
                    "pub",
                    "pw",
                    "py",
                    "qa",
                    "qpon",
                    "quebec",
                    "re",
                    "realtor",
                    "recipes",
                    "red",
                    "rehab",
                    "reise",
                    "reisen",
                    "ren",
                    "rentals",
                    "repair",
                    "report",
                    "republican",
                    "rest",
                    "restaurant",
                    "reviews",
                    "rich",
                    "rio",
                    "ro",
                    "rocks",
                    "rodeo",
                    "rs",
                    "ru",
                    "ruhr",
                    "rw",
                    "ryukyu",
                    "sa",
                    "saarland",
                    "sarl",
                    "sb",
                    "sc",
                    "sca",
                    "scb",
                    "schmidt",
                    "schule",
                    "scot",
                    "sd",
                    "se",
                    "services",
                    "sexy",
                    "sg",
                    "sh",
                    "shiksha",
                    "shoes",
                    "si",
                    "singles",
                    "sj",
                    "sk",
                    "sl",
                    "sm",
                    "sn",
                    "so",
                    "social",
                    "software",
                    "sohu",
                    "solar",
                    "solutions",
                    "soy",
                    "space",
                    "spiegel",
                    "sr",
                    "st",
                    "su",
                    "supplies",
                    "supply",
                    "support",
                    "surf",
                    "surgery",
                    "suzuki",
                    "sv",
                    "sx",
                    "sy",
                    "systems",
                    "sz",
                    "tatar",
                    "tattoo",
                    "tax",
                    "tc",
                    "td",
                    "technology",
                    "tel",
                    "tf",
                    "tg",
                    "th",
                    "tienda",
                    "tips",
                    "tirol",
                    "tj",
                    "tk",
                    "tl",
                    "tm",
                    "tn",
                    "to",
                    "today",
                    "tokyo",
                    "tools",
                    "top",
                    "town",
                    "toys",
                    "tp",
                    "tr",
                    "trade",
                    "training",
                    "travel",
                    "tt",
                    "tv",
                    "tw",
                    "tz",
                    "ua",
                    "ug",
                    "uk",
                    "university",
                    "uno",
                    "uol",
                    "us",
                    "uy",
                    "uz",
                    "va",
                    "vacations",
                    "vc",
                    "ve",
                    "vegas",
                    "ventures",
                    "versicherung",
                    "vet",
                    "vg",
                    "vi",
                    "viajes",
                    "villas",
                    "vision",
                    "vlaanderen",
                    "vn",
                    "vodka",
                    "vote",
                    "voting",
                    "voto",
                    "voyage",
                    "vu",
                    "wales",
                    "wang",
                    "watch",
                    "webcam",
                    "website",
                    "wed",
                    "wf",
                    "whoswho",
                    "wien",
                    "wiki",
                    "williamhill",
                    "works",
                    "ws",
                    "wtc",
                    "wtf",
                    "xn--1qqw23a",
                    "xn--3bst00m",
                    "xn--3ds443g",
                    "xn--3e0b707e",
                    "xn--45brj9c",
                    "xn--4gbrim",
                    "xn--55qw42g",
                    "xn--55qx5d",
                    "xn--6frz82g",
                    "xn--6qq986b3xl",
                    "xn--80adxhks",
                    "xn--80ao21a",
                    "xn--80asehdb",
                    "xn--80aswg",
                    "xn--90a3ac",
                    "xn--c1avg",
                    "xn--cg4bki",
                    "xn--clchc0ea0b2g2a9gcd",
                    "xn--czr694b",
                    "xn--czru2d",
                    "xn--d1acj3b",
                    "xn--fiq228c5hs",
                    "xn--fiq64b",
                    "xn--fiqs8s",
                    "xn--fiqz9s",
                    "xn--fpcrj9c3d",
                    "xn--fzc2c9e2c",
                    "xn--gecrj9c",
                    "xn--h2brj9c",
                    "xn--i1b6b1a6a2e",
                    "xn--io0a7i",
                    "xn--j1amh",
                    "xn--j6w193g",
                    "xn--kprw13d",
                    "xn--kpry57d",
                    "xn--kput3i",
                    "xn--l1acc",
                    "xn--lgbbat1ad8j",
                    "xn--mgb9awbf",
                    "xn--mgba3a4f16a",
                    "xn--mgbaam7a8h",
                    "xn--mgbab2bd",
                    "xn--mgbayh7gpa",
                    "xn--mgbbh1a71e",
                    "xn--mgbc0a9azcg",
                    "xn--mgberp4a5d4ar",
                    "xn--mgbx4cd0ab",
                    "xn--ngbc5azd",
                    "xn--nqv7f",
                    "xn--nqv7fs00ema",
                    "xn--o3cw4h",
                    "xn--ogbpf8fl",
                    "xn--p1ai",
                    "xn--pgbs0dh",
                    "xn--q9jyb4c",
                    "xn--rhqv96g",
                    "xn--s9brj9c",
                    "xn--ses554g",
                    "xn--unup4y",
                    "xn--wgbh1c",
                    "xn--wgbl6a",
                    "xn--xhq521b",
                    "xn--xkc2al3hye2a",
                    "xn--xkc2dl3a5ee0h",
                    "xn--yfro4i67o",
                    "xn--ygbi2ammx",
                    "xn--zfr164b",
                    "xxx",
                    "xyz",
                    "yachts",
                    "yandex",
                    "ye",
                    "yokohama",
                    "yt",
                    "za",
                    "zm",
                    "zone",
                    "zw"
                    ];


        if (inUri.tld) {
            for (var i=0,t;t=tld[i];i++) {
				if (inUri.tld.toLowerCase() === t) {
					return true;
				}
			}
		}
	}
	
	function isValidScheme (inUri) {
		var scheme = inUri.scheme ? inUri.scheme.toLowerCase() : "";
		if (!scheme || scheme === "http" || scheme === "https" || scheme === "data" || scheme === "ftp" || scheme === "about" || scheme === "file") {
			return true;
		}
	}

    function isUri (inText, inUri) {
        // probably a search term if there is a space
        //TODO investigate MATCH
        /*if (inText.match('/\s/')) {
            console.log("no valid url")
            return false;
        }*/
        return isValidUri(inUri);
    }

	

/**
	Populates a string template with data values.

	Returns a copy of _inText_, with macros defined by _inPattern_ replaced by
	named values in _inMap_.

	_inPattern_ may be omitted, in which case the default macro pattern is used. 
	The default pattern matches macros of the form

		{$name}

	Example:

		// returns "My name is Barney."
		macroize("My name is {$name}.", {name: "Barney"});

	Dot notation is supported, like so:

		var info = {
			product_0: {
				name: "Gizmo"
				weight: 3
			}
		}
		// returns "Each Gizmo weighs 3 pounds."
		macroize("Each {$product_0.name} weighs {$product_0.weight} pounds.", info);
*/
function macroize (inText, inMap, inPattern) {
var mypattern = /{\$([^{}]*)}/g;
	var v, working, result = inText, pattern = inPattern || mypattern;
	var fn = function(macro, name) {
		working = true;
		v = getObject(name, false, inMap);
		//v = inMap[name];
		return (v === undefined || v === null) ? "{$" + name + "}" : v;
	};
	var prevent = 0;
	do {
		working = false;
		result = result.replace(pattern, fn);
	// if iterating more than 100 times, we assume a recursion (we should throw probably)
	} while (working && (prevent++ < 100));
	return result;
};

function getObject(name, create, context) {
	return _getProp(name.split("."), create, context);
};
	
var myglobal = this;

function getProp(parts, create, context) {
		var obj = context || myglobal;
		for(var i=0, p; obj && (p=parts[i]); i++){
			obj = (p in obj ? obj[p] : (create ? obj[p]={} : undefined));
		}
		return obj; // mixed
	};

	function _getProp (parts, create, context) {
		var obj = context //|| enyo.global;
		for(var i=0, p; obj && (p=parts[i]); i++){
			obj = (p in obj ? obj[p] : (create ? obj[p]={} : undefined));
		}
		return obj; // mixed
	};

	//* @public

	/**
		Sets object _name_ to _value_. _name_ can use dot notation and intermediate objects are created as necessary.

			// set foo.bar.baz to 3. If foo or foo.bar do not exist, they are created.
			enyo.setObject("foo.bar.baz", 3); 

		Optionally, _name_ can be relative to object _context_.

			// create foo.zot and sets foo.zot.zap to null.
			enyo.setObject("zot.zap", null, foo);
	*/
	function setObject(name, value, context) {
		//var parts=name.split("."), p=parts.pop(), obj=enyo._getProp(parts, true, context);
		var parts=name.split("."), p=parts.pop(), obj=_getProp(parts, true, context);
		return obj && p ? (obj[p]=value) : undefined;
	};

	/**
		Gets object _name_. _name_ can use dot notation. Intermediate objects are created if _create_ argument is truthy.

			// get the value of foo.bar, or undefined if foo doesn't exist.
 			var value = enyo.getObject("foo.bar");

			// get the value of foo.bar. If foo.bar doesn't exist, 
			// it's assigned an empty object, which is returned
			var value = enyo.getObject("foo.bar", true);

		Optionally, _name_ can be relative to object _context_.

			// get the value of foo.zot.zap, or undefined if foo.zot doesn't exist
			var value = enyo.getObject("zot.zap", false, foo); 
	*/
	function getObject(name, create, context) {
		return _getProp(name.split("."), create, context);
		//return enyo._getProp(name.split("."), create, context);
	};
	
	//* Returns inString with the first letter capitalized.
	function cap(inString) {
		return inString.slice(0, 1).toUpperCase() + inString.slice(1);
	};

	//* Returns inString with the first letter un-capitalized.
	function uncap(inString) {
		return inString.slice(0, 1).toLowerCase() + inString.slice(1);
	};

	//* Returns true if _it_ is a string.
	function isString (it) {
		return (typeof it == "string" || it instanceof String);
	};
	
	//* Returns true if _it_ is a function.
	function isFunction (it) {
		return typeof it == "function";
	};
	
	//* Returns true if _it_ is an array.
	function isArray (it) {
		return Object.prototype.toString.apply(it) === '[object Array]';
	};

	if (Array.isArray) {
		isArray = Array.isArray;
		//enyo.isArray = Array.isArray;
	}
	
	//* Returns the index of the element in _inArray_ that is equivalent (==) to _inElement_, or -1 if no element is found.
	function indexOf (inElement, inArray) {
		for (var i=0, e; e=inArray[i]; i++) {
			if (e == inElement) {
				return i;
			}
		}
		return -1;
	};

	//* Removes the first element in _inArray_ that is equivalent (==) to _inElement_.
	function remove (inElement, inArray) {
		var i = indexOf(inElement, inArray);
		//var i = enyo.indexOf(inElement, inArray);
		if (i >= 0) {
			inArray.splice(i, 1);
		}
	};

	/**
		Invokes _inFunc_ on each element of _inArray_.
		Returns an array (map) of the return values from each invocation of _inFunc_.
		If _inContext_ is specified, _inFunc_ is called with _inContext_ as _this_.

		Aliased as _enyo.map_.
	*/
	function forEach(inArray, inFunc, inContext) {
		var result = [];
		if (inArray) {
			var context = inContext || this;
			for (var i=0, l=inArray.length; i<l; i++) {
				result.push(inFunc.call(context, inArray[i], i, inArray));
			}
		}
		return result;
	};
	//enyo.map=enyo.forEach;
	var map = forEach();

	/**
		Clones an existing Array, or converts an array-like object into an Array.
		
		If _inOffset_ is non-zero, the cloning is started from that index in the source Array.
		The clone may be appended to an existing Array by passing the existing Array as _inStartWith_.

		Array-like objects have _length_ properties, and support square-bracket notation ([]).
		Often array-like objects do not support Array methods, such as _push_ or _concat_, and
		must be converted to Arrays before use. 
		The special _arguments_ variable is an example of an array-like object.
	*/
	function cloneArray(inArrayLike, inOffset, inStartWith) {
		
		var arr = inStartWith || [];
		if(inArrayLike)
		{
			for(var i = inOffset || 0, l = inArrayLike.length; i<l; i++){
				arr.push(inArrayLike[i]);
			}
		}	
		return arr;
			
	};
	//enyo._toArray = enyo.cloneArray;
	var _toArray = cloneArray();

	/**
		Shallow-clones an object or an array.
	*/
	function clone(obj) {
		return isArray(obj) ? cloneArray(obj) : mixin({}, obj);
		//return enyo.isArray(obj) ? enyo.cloneArray(obj) : enyo.mixin({}, obj);
	};

	//* @protected
	var empty = {};

	//* @public
	/**
		Copies custom properties from the _source_ object to the _target_ object.
		If _target_ is falsey, an object is created.
		If _source_ is falsey, the target or empty object is returned.
	*/
	 function mixin (target, source) {
		target = target || {};
		if (source) {
			var name, s, i;
			for (name in source) {
				// the "empty" conditional avoids copying properties in "source"
				// inherited from Object.prototype.  For example, if target has a custom
				// toString() method, don't overwrite it with the toString() method
				// that source inherited from Object.prototype
				s = source[name];
				if (empty[name] !== s) {
					target[name] = s;
				}
			}
		}
		return target; 
	};

	//* @protected
	function _hitchArgs (scope, method /*,...*/){
		//var pre = enyo._toArray(arguments, 2);
		//var named = enyo.isString(method);
		var pre = _toArray(arguments, 2);
		var named = isString(method);
		return function(){
			// arrayify "arguments"
			var args = _toArray(arguments);
			//var args = enyo._toArray(arguments);
			// locate our method
			var fn = named ? (scope||myglobal)[method] : method;
			//var fn = named ? (scope||enyo.global)[method] : method;
			// invoke with collected args
			return fn && fn.apply(scope || this, pre.concat(args));
		} 
	};

	//* @public
	/**
		Returns a function closure that will call (and return the value of) function _method_, with _scope_ as _this_.
		
		Method can be a function or the string name of a function-valued property on _scope_.

		Arguments to the closure are passed into the bound function.
		
			// a function that binds this to this.foo
			var fn = enyo.bind(this, "foo");
			// the value of this.foo(3)
			var value = fn(3);

		Optionally, any number of arguments can be prefixed to the bound function.

			// a function that binds this to this.bar, with arguments ("hello", 42)
			var fn = enyo.bind(this, "bar", "hello", 42);
			// the value of this.bar("hello", 42, "goodbye");
			var value = fn("goodbye");

		Functions can be bound to any scope.

			// binds function 'bar' to scope 'foo'
			var fn = enyo.bind(foo, bar);
			// the value of bar.call(foo);
			var value = fn();
	*/
	function bind(scope, method/*, bound arguments*/){
		if (arguments.length > 2) {
			//return enyo._hitchArgs.apply(enyo, arguments);
			return _hitchArgs.apply(enyo, arguments);
		}
		if (!method) {
			method = scope;
			scope = null;
		}
		//if (enyo.isString(method)) {
		if (isString(method)) {
			//scope = scope || enyo.global;
			scope = scope || myglobal;
			if(!scope[method]){ throw(['bind: scope["', method, '"] is null (scope="', scope, '")'].join('')); }
			//if(!scope[method]){ throw(['enyo.bind: scope["', method, '"] is null (scope="', scope, '")'].join('')); }
			return function(){ return scope[method].apply(scope, arguments || []); };
		}
		return !scope ? method : function(){ return method.apply(scope, arguments || []); };
	};
	/* add alias for older code */
	//enyo.hitch = enyo.bind;
	var hitch = bind();

	//* @protected

	function nop(){};
	//enyo.nob = {};
	var nob = {};
	
	// some platforms need alternative syntax (e.g., when compiled as a v8 builtin)
	if (!setPrototype) {
	//if (!enyo.setPrototype) {
        function setPrototype (ctor, proto) {
		//enyo.setPrototype = function(ctor, proto) {
			ctor.prototype = proto;
		};
	}
	
	// this name is reported in inspectors as the type of objects created via delegate, 
	// otherwise we would just use enyo.nop
	function instance() {};

	// boodman/crockford delegation w/cornford optimization
	 function delegate(obj) {
		setPrototype(instance, obj);
		return new instance();
		//enyo.setPrototype(enyo.instance, obj);
		//return new enyo.instance();
		//var obj = new enyo.instance();
		//enyo.setPrototype(enyo.nop, null);
		//return obj;
	};
	
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
    var msg = ("Here's a website I think you'll like: <a href=\"{$src}\">{$title}</a>")

    msg = macroize(msg, {
                                                 src: inUrl,
                                                 title: inTitle
                                                        || inUrl
                                             })

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
            appWindow.__queryDB("merge", JSON.stringify({objects: [b]}));
        };

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
         appWindow.__queryPutDB(b)
        //this.$.bookmarksService.call({objects: [b]}, {method: "put"});

    };

    function addToLauncher(inTitle, inUrl, inIcons) {
        var appParams = {
                    "url": inUrl
                };

        var callParams = {
            "id": "org.webosports.app.browser",
            "icon": inIcons,
            "title": inTitle,
            "params": appParams
        };

        console.log("callparams: "+callParams)
        console.log("JSON.stringify(callParams): "+JSON.stringify({parameters: callParams}))

        luna.call("luna://com.palm.applicationManager/addLaunchPoint", JSON.stringify(callParams),
                  __handleAddLaunchPointSuccess, __handleAddLaunchPointError);
    };

    function __handleAddLaunchPointSuccess(message) {
        console.log("Successfully added App Launchpoint : " + message.payload);
    };

    function __handleAddLaunchPointError(message) {
        console.log("Could not start application : " + message.payload);
    };

