sselib
======
_SSE (Server Sent Events) library for node.js._

`sselib` is a full implementation of `SSE` written in `Coffee Script` for the `node.js` platform.


## Connect and Express Middleware ##
sselib can also be used as a middleware:

    sselib = require('sselib')
    ...
    app.use(sselib.middleware())
    ...
    app.get('/events', function(req, res) {
        res.sse(
            {id: 5364,
             event: 'update',
             data: 'I am a stray cat.'
            }
        );
        
    });

## Get strings ready for your own transmission ##
    sselib = require('sselib')
    sselib.event("notice") // "event: notice\n"
    sselib.data("Hello there!") // "data: Hello there!\n\n"

### Available types:
* comment
* event
* id
* data

## License ##
![massförströelse logo](http://www.massforstroel.se/uploads/4/3/3/4/4334921/4793588.png?20)  
Made by [massförströelse](http://massforstroel.se/ "massförströel.se")  
BSD (see [LICENSE.md](https://github.com/massforstroelse/sselib.js/blob/master/LICENSE.md "LICENSE.md"))  
