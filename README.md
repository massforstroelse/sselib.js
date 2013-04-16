[![sselib.js](http://dl.dropboxusercontent.com/u/15640279/massforstroelse-site/sse-lib.png)](https://npmjs.org/package/sselib)

_SSE (Server Sent Events) library for node.js._

`sselib` is a implementation of the server-side part of the [SSE] [1] protocol written in `Coffee Script` for the `node.js` platform.

[![Build Status](https://travis-ci.org/massforstroelse/sselib.js.png)](https://travis-ci.org/massforstroelse/sselib.js)

  [1]: http://dev.w3.org/html5/eventsource/

## Installation ##

### Install with npm: ###

    $ npm install sselib

### Requirements ###

None, tested on node.js 0.6 >

## Connect and Express Middleware ##

`sselib` can be used as a middleware for applications following the Connect convention.

### Example ###

#### Javascript ####

```javascript
    var sselib = require('sselib'),
    express = require('express');

    var app = express();
    
    app.use(sselib.middleware());
    
    app.get('/events', function(req, res) {
        res.sse(
            {id: 5364,
             event: 'update',
             data: 'I am a stray cat.'
            }
        );
        
    });

    app.listen(3000);
```

#### Coffeescript ####

```coffeescript
    sselib = require 'sselib'
    express = require 'express'

    app = express()

    app.use sselib.middleware()
    
    app.get '/events', (req, res) ->
      res.sse
        id: 5364
        event: 'update'
        data: 'I am a stray cat.'
```

### Options ###

You can pass options when initializing the middleware.

```javascript
    app.use(sselib.middleware({
        retry: 5*1000,
        keepAlive: 15*1000,
        compatibility: true
    });
```

#### retry ####

The time in milliseconds for client reconnects. Default is 5 seconds.  
Set to `false` in order to disable.

#### keepAlive ####

Sends pseudo keep alive heartbeats in order to keep the connection open. The value is the amount of milliseconds between each keepAlive heartbeat. Default is 15 seconds.  
Set to `false` in order to disable.

#### compatibility ####

"Quirk mode". Adds support for some polyfills and the way MSIE handles XDomainRequest. Default is `true`  
Set to `false` in order to disable.

## Use as a library to serialize data for your own transmission ##

### Example ###

```javascript
    var sselib = require('sselib');

    console.log(sselib.event("notice")); // "event: notice\n"
    console.log(sselib.data("Hello there!")); // "data: Hello there!\n\n"

    // or:
    
    sselib.data("Hello there!", function(err, result) {
        if (err) {
            // handle the error safely
            console.log(err);
            return;
            }
        console.log(result) // "data: Hello there!\n\n"
        });
```

### Serializers ###

#### sselib.comment(comment [, callback]) ####

Returns a SSE-serialized comment `string` representing a comment (please note that comments are invisible to browser clients).

#### sselib.event(event [, callback]) ####

Returns a SSE-serialized event `string` that can be used with a following `data` type to trigger a event in the browser.

#### sselib.id(id [, callback]) ####

Returns a SSE-serialized id `string`. If called without `id` it will use a `UNIX timestamp` as the `id`.

#### sselib.data(data [, callback]) ####

Returns a SSE-serialized data `string`.

#### sselib.message(obj [, callback]) ####

`message` is provided as a meta-serializer. It will return a SSE-serialized string from a message object you pass in.

#### sselib.headers([callback]) ####

Returns a `Object` containing valid HTTP-headers suitable for a `http.ServerResponse`.

## Concepts ##

### Message Object ###

[![sselib.message() graph](http://dl.dropboxusercontent.com/u/15640279/massforstroelse-site/sselib-serialization-graph.png)](https://npmjs.org/package/sselib)

A `message object` is simply a javascript object containing the `data` and `event` keys, it can also optionally be given a `id` key.

#### Example ####

    {event: 'update', data: 'I am a stray cat.'}

## License ##

BSD (see [LICENSE.md](https://github.com/massforstroelse/sselib.js/blob/master/LICENSE.md "LICENSE.md"))  

Made by [massförströelse](http://massforstroel.se/ "massförströel.se")  

