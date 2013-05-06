0.0.9
=====

  * Added support for lastEventID as querystring.

0.0.8
=====

  * Added _socket to middleware.

0.0.7
=====

  * Using response.setHeader instead of writing them out.

0.0.6
=====

  * Correctified the repo url.
  * Changed name of changelog.

0.0.5
=====

  * Refactoring middleware to only expose middleware specific properties.
  * Added toString serialization.
  * Making keepalive timer private.
  * Adding module.exports.utils ns.
  * Middleware only calls next() if available.

0.0.4
=====

  * Added express as a dev dep.
  * Added tests for middleware instance.
  * Placing instance vars directly under res.sse for middleware.
  * Implemented get() and set().

0.0.3
=====

  * Added options.compatibility, this closes [#9](https://github.com/massforstroelse/sselib.js/issues/9)
  * Retry can be set to false, then no initial retry message will be sent to the client. This closes [#5](https://github.com/massforstroelse/sselib.js/issues/5).
  * _ prepending internal utils.
  * Changed internal interface for middleware.
  * Added graph to readme.
  * Data now splits to multiple data-lines on linefeed.

0.0.2
=====

  * Added logo to docs, this closes [#8](https://github.com/massforstroelse/sselib.js/issues/8).
  * Changed extend implemention in order to target node =< .6

0.0.1
=====

  * Implementing error as first arg in callbacks.
  * Added callbacks to message types.
  * Using versions instead of latest in npm deps.
  * Added req, res and options to testcase.
  * Making better use of header setting, this closes [#2](https://github.com/massforstroelse/sselib.js/issues/2).

0.0.1-beta
==========

  * First release.
