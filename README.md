# sselib #

_SSE (Server Sent Events) library for node.js._

`sselib` is a implementation of the server-side part of the [SSE] [1] protocol written in `Coffee Script` for the `node.js` platform.

  [1]: http://dev.w3.org/html5/eventsource/

## Installation ##

Install with npm:

    $ npm install sselib

## Connect and Express Middleware ##

`sselib` can be used as a middleware for applications following the Connect convention.

### Example ###

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

## Use as a library to serialize data for your own transmission ##

### Example ###

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

### Available messages ###

#### comment(comment, [callback]) ####

Returns a SSE-serialized `string` representing a comment.

#### event(event, [callback]) ####

Returns a SSE-serialized `string` that can be used with a following `data` type to trigger a event in the browser.

#### id([id], [callback]) ####

Returns a SSE-serialized `string`. If called without `id` it will use a `UNIX timestamp` as the `id`.

#### data(data, [callback]) ####

Returns a SSE-serialized `string`.

#### message(obj, [callback]) ####

`message` is provided as a meta-messagetype. It will return a SSE-serialized string from a message object you pass in.

#### headers([callback]) ####

Returns a `Object` containing valid HTTP-headers suitable for a `http.ServerResponse`.

## Concepts ##

### Message Object ###

A `message object` is simply a javascript object containing the `data` and `event` keys, it can also optionally be given a `id` key.

#### Example ####
    {id: 5364, event: 'update', data: 'I am a stray cat.'}

## License ##

![massförströelse logo](http://www.massforstroel.se/uploads/4/3/3/4/4334921/4793588.png?20)  
Made by [massförströelse](http://massforstroel.se/ "massförströel.se")  
BSD (see [LICENSE.md](https://github.com/massforstroelse/sselib.js/blob/master/LICENSE.md "LICENSE.md"))  
