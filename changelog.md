0.0.6
=====

  * Correctified the repo url
  * Changed name of changelog

0.0.5
=====

  * refactoring middleware to only expose middleware specific properties
  * adding toString serialization
  * making keepalive timer private
  * adding module.exports.utils ns
  * middleware only calls next() if available

0.0.4
=====

  * adding express as a dev dep
  * adding tests for middleware instance
  * placing instance vars directly under res.sse for middleware
  * implemented get() and set()

0.0.3
=====

  * added options.compatibility, this closes [#9](https://github.com/massforstroelse/sselib.js/issues/9)
  * retry can be set to false, then no initial retry message will be sent to the client. This closes [#5](https://github.com/massforstroelse/sselib.js/issues/5)
  * _ prepending internal utils
  * changed internal interface for middleware
  * added graph to readme
  * data now splits to multiple data-lines on linefeed

0.0.2
=====

  * added logo to docs, this closes [#8](https://github.com/massforstroelse/sselib.js/issues/8)
  * changed extend implemention in order to target node =< .6

0.0.1
=====

  * implementing error as first arg in callbacks
  * added callbacks to message types
  * using versions instead of latest in npm deps
  * adding req, res and options to testcase
  * making better use of header setting, this closes [#2](https://github.com/massforstroelse/sselib.js/issues/2)

0.0.1-beta
==========

  * First release.
