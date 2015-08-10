retryable gem
=====

[![Build Status](https://travis-ci.org/nfedyashev/retryable.png?branch=master)](https://travis-ci.org/nfedyashev/retryable)

Description
--------

Runs a code block, and retries it when an exception occurs. It's great when
working with flakey webservices (for example).

It's configured using five optional parameters `:tries`, `:on`, `:sleep`, `:matching`, `:ensure`, `:exception_cb`, `:not` and
runs the passed block. Should an exception occur, it'll retry for (n-1) times.

Should the number of retries be reached without success, the last exception
will be raised.


Examples
--------

Open an URL, retry up to two times when an `OpenURI::HTTPError` occurs.

``` ruby
require "open-uri"

Retryable.retryable(:tries => 3, :on => OpenURI::HTTPError) do
  xml = open("http://example.com/test.xml").read
end
```

Do _something_, retry up to four times for either `ArgumentError` or
`TimeoutError` exceptions.

``` ruby
Retryable.retryable(:tries => 5, :on => [ArgumentError, TimeoutError]) do
  # some crazy code
end
```

Ensure that block of code is executed, regardless of whether an exception was raised. It doesn't matter if the block exits normally, if it retries to execute block of code, or if it is terminated by an uncaught exception -- the ensure block will get run.

``` ruby
f = File.open("testfile")

ensure_cb = Proc.new do |retries|
  puts "total retry attempts: #{retries}"

  f.close
end

Retryable.retryable(:ensure => ensure_cb) do
  # process file
end
```

## Defaults

    :tries => 2, :on => StandardError, :sleep => 1, :matching  => /.*/, :ensure => Proc.new { }, :exception_cb => Proc.new { }, :not => []

Retryable also could be configured globally to change those defaults:

```
Retryable.configure do |config|
  config.ensure       = Proc.new {}
  config.exception_cb = Proc.new {}
  config.matching     = /.*/
  config.on           = StandardError
  config.sleep        = 1
  config.tries        = 2
  config.not          = []
end
```


Sleeping
--------
By default Retryable waits for one second between retries. You can change this and even provide your own exponential backoff scheme.

```
Retryable.retryable(:sleep => 0) { }                     # don't pause at all between retries
Retryable.retryable(:sleep => 10) { }                    # sleep ten seconds between retries
Retryable.retryable(:sleep => lambda { |n| 4**n }) { }   # sleep 1, 4, 16, etc. each try
```

Matching error messages
--------
You can also retry based on the exception message:

```
Retryable.retryable(:matching => /IO timeout/) do |retries, exception|
  raise "yo, IO timeout!" if retries == 0
end
```

Block Parameters
--------
Your block is called with two optional parameters: the number of tries until now, and the most recent exception.

```
Retryable.retryable do |retries, exception|
  puts "try #{retries} failed with exception: #{exception}" if retries > 0
  pick_up_soap
end
```

Callback to run after an exception is rescued
--------

```
exception_cb = Proc.new do |exception|
  # http://smartinez87.github.io/exception_notification
  ExceptionNotifier.notify_exception(exception, :data => {:message => "it failed"})
end

Retryable.retryable(:exception_cb => exception_cb) do
  # perform risky operation
end
```

You can temporary disable retryable blocks
--------

```
Retryable.enabled?
=> true

Retryable.disable

Retryable.enabled?
=> false
```

Specify exceptions where a retry should NOT be performed
--------
No more tries will be made if an exception listed in `:not` is raised.
Takes precedence over `:on`.

```
class MyError < StandardError; end

Retryable.retryable(:tries => 5, :on => [StandardError], :not => [MyError]) do
  raise MyError "No retries!"
end

```

Supported Ruby Versions
-------

This library aims to support and is [tested against][travis] the following Ruby
versions:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0
* Ruby 2.1.2
* Ruby 2.2.0

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions,
however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or
implementation, you may volunteer to be a maintainer.


Installation
-------

Install the gem:

``` bash
$ gem install retryable
```

Add it to your Gemfile:

``` ruby
gem 'retryable'
```

## Thanks

[Chu Yeow for this nifty piece of code](http://blog.codefront.net/2008/01/14/retrying-code-blocks-in-ruby-on-exceptions-whatever/)

[Scott Bronson](https://github.com/bronson/retryable)

[travis]: http://travis-ci.org/nfedyashev/retryable
