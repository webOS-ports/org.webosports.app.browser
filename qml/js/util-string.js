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

.pragma library

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
