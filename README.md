
[![Travis](https://img.shields.io/travis/PGSSoft/danger-ios_logs.svg)](https://travis-ci.org/PGSSoft/danger-ios_logs)
[![Gem](https://img.shields.io/gem/v/danger-ios_logs.svg)](https://rubygems.org/gems/danger-ios_logs)
[![License](https://img.shields.io/github/license/PGSSoft/danger-ios_logs.svg)](https://github.com/PGSSoft/danger-ios_logs/blob/master/LICENSE)

### ios_logs

This is a danger plugin to detect any `NSLog`/`print` entries left in the code.

<blockquote>Ensure, by warning, there are no `NSLog`/`print` entries left in the modified code
  <pre>
ios_logs.check</pre>
</blockquote>

<blockquote>Ensure, by fail, there are no `NSLog`/`print` entries left in the modified code
  <pre>
ios_logs.check :fail</pre>
</blockquote>

<blockquote>Ensure, there are no `print` left in the modified code. Ignore `NSLog`
  <pre>
ios_logs.nslog = false
ios_logs.check</pre>
</blockquote>



#### Attributes

`nslog` - Notify usage of `NSLog`. `true` by default

`print` - Notify usage of `print`. `true` by default

`prints` - List of `print` in changeset

`nslogs` - List of `NSLog` in changeset

`logs` - Combined list of both `NSLog` and `print`




#### Methods

`check` - Checks if in the changed code `NSLog` or `print` are used.


## License

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About
The project maintained by [software development agency](https://www.pgs-soft.com/) [PGS Software](https://www.pgs-soft.com/)
See our other [open-source projects](https://github.com/PGSSoft) or [contact us](https://www.pgs-soft.com/contact-us/) to develop your product.

## Follow us

[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/PGSSoft/danger-ios_logs)  
[![Twitter Follow](https://img.shields.io/twitter/follow/pgssoftware.svg?style=social&label=Follow)](https://twitter.com/pgssoftware)

