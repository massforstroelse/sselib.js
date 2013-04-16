![](http://dl.dropboxusercontent.com/u/15640279/massforstroelse-site/sse-lib.png)

_SSE (Server Sent Events) library for node.js._

`sselib` is a implementation of the server-side part of the [SSE] [1] protocol written in `Coffee Script` for the `node.js` platform.

[![Build Status](https://travis-ci.org/massforstroelse/sselib.js.png)](https://travis-ci.org/massforstroelse/sselib.js)

  [1]: http://dev.w3.org/html5/eventsource/

## Installation ##

Install with npm:

    $ npm install sselib

## Connect and Express Middleware ##

`sselib` can be used as a middleware for applications following the Connect convention.

### Example ###
```javascript
    sselib = require('sselib');
    ...
    app.use(sselib.middleware());
    ...
    app.get('/events', function(req, res) {
        res.sse(
            {id: 5364,
             event: 'update',
             data: 'I am a stray cat.'
            }
        );
        
    });
```

```coffeescript
    sselib = require 'sselib'
    ...
    app.use sselib.middleware()
    ...
    app.get '/events', (req, res) ->
      res.sse
        id: 5364
        event: 'update'
        data: 'I am a stray cat.'
```

## Use as a library to serialize data for your own transmission ##

### Example ###

```javascript
    sselib = require('sselib');

    sselib.event("notice") // "event: notice\n"
    sselib.data("Hello there!") // "data: Hello there!\n\n"

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

