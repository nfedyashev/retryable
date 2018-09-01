# Retryable

[![Gem Version](https://badge.fury.io/rb/retryable.svg)](https://badge.fury.io/rb/retryable)
[![Build Status](https://travis-ci.org/nfedyashev/retryable.png?branch=master)](https://travis-ci.org/nfedyashev/retryable)
[![Code Climate](https://codeclimate.com/github/nfedyashev/retryable/badges/gpa.svg)](https://codeclimate.com/github/nfedyashev/retryable)
[![Test Coverage](https://codeclimate.com/github/nfedyashev/retryable/badges/coverage.svg)](https://codeclimate.com/github/nfedyashev/retryable/coverage)

[![Inline docs](http://inch-ci.org/github/nfedyashev/retryable.svg?branch=master)](http://inch-ci.org/github/nfedyashev/retryable)

Description
--------

Runs a code block, and retries it when an exception occurs. It's great when
working with flakey webservices (for example).

It's configured using several optional parameters `:tries`, `:on`, `:sleep`, `:matching`, `:ensure`, `:exception_cb`, `:not`, `:sleep_method` and
runs the passed block. Should an exception occur, it'll retry for (n-1) times.

Should the number of retries be reached without success, the last exception
will be raised.

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


Examples
--------

Open an URL, retry up to two times when an `OpenURI::HTTPError` occurs.

``` ruby
require "open-uri"

Retryable.retryable(tries: 3, on: OpenURI::HTTPError) do
  xml = open("http://example.com/test.xml").read
end
```

Try the block forever.
```ruby
Retryable.retryable(tries: :infinite) do
  # code here
end
```

Do something, retry up to four times for either `ArgumentError` or
`Timeout::Error` exceptions.

``` ruby
Retryable.retryable(tries: 5, on: [ArgumentError, Timeout::Error]) do
  # code here
end
```

Ensure that block of code is executed, regardless of whether an exception was raised. It doesn't matter if the block exits normally, if it retries to execute block of code, or if it is terminated by an uncaught exception -- the ensure block will get run.

``` ruby
f = File.open("testfile")

ensure_cb = proc do |retries|
  puts "total retry attempts: #{retries}"

  f.close
end

Retryable.retryable(ensure: ensure_cb) do
  # process file
end
```

## Defaults

    contexts: {},
    ensure: proc { },
    exception_cb: proc { },
    logger: Logger.new(IO::NULL),
    matching : /.*/,
    not: [],
    on: StandardError,
    sleep: 1,
    sleep_method: lambda { |n| Kernel.sleep(n) },
    tries: 2

Retryable also could be configured globally to change those defaults:

```ruby
Retryable.configure do |config|
  config.contexts     = {}
  config.ensure       = proc {}
  config.exception_cb = proc {}
  config.logger       = Logger.new(IO:NULL)
  config.matching     = /.*/
  config.not          = []
  config.on           = StandardError
  config.sleep        = 1
  config.sleep_method = Celluloid.method(:sleep)
  config.tries        = 2
end
```


Sleeping
--------
By default Retryable waits for one second between retries. You can change this and even provide your own exponential backoff scheme.

```ruby
Retryable.retryable(sleep: 0) { }                     # don't pause at all between retries
Retryable.retryable(sleep: 10) { }                    # sleep ten seconds between retries
Retryable.retryable(sleep: lambda { |n| 4**n }) { }   # sleep 1, 4, 16, etc. each try
```

Matching error messages
--------
You can also retry based on the exception message:

```ruby
Retryable.retryable(matching: /IO timeout/) do |retries, exception|
  raise "oops IO timeout!" if retries == 0
end

#matching param supports array format as well:
Retryable.retryable(matching: [/IO timeout/, "IO tymeout"]) do |retries, exception|
  raise "oops IO timeout!" if retries == 0
end
```

Block Parameters
--------
Your block is called with two optional parameters: the number of tries until now, and the most recent exception.

```ruby
Retryable.retryable do |retries, exception|
  puts "try #{retries} failed with exception: #{exception}" if retries > 0
  # code here
end
```

Callback to run after an exception is rescued
--------

```ruby
exception_cb = proc do |exception|
  # http://smartinez87.github.io/exception_notification
  ExceptionNotifier.notify_exception(exception, data: {message: "it failed"})
end

Retryable.retryable(exception_cb: exception_cb) do
  # code here
end
```

Contexts
--------

Contexts allow you to extract common `Retryable.retryable` calling options for reuse or readability purposes.

```ruby
Retryable.configure do |config|
  config.contexts[:faulty_service] = {
    :on: [FaultyServiceTimeoutError],
    :sleep: 10,
    :tries: 5
  }
end


Retryable.with_context(:faulty_service) {
  # code here
}
```

You may also override options defined in your contexts:

```ruby
# :on & sleep defined in the context earlier are still effective
Retryable.with_context(:faulty_service, tries: 999) {
  # code here
}
```


You can temporary disable retryable blocks
--------

```ruby
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

```ruby
class MyError < StandardError; end

Retryable.retryable(tries: 5, on: [StandardError], not: [MyError]) do
  raise MyError "No retries!"
end

```

Specify the sleep method to use
--------
This can be very useful when you are working with [Celluloid](https://github.com/celluloid/celluloid)
which implements its own version of the method sleep.

```ruby
Retryable.retryable(sleep_method: Celluloid.method(:sleep)) do
  # code here
end
```

Supported Ruby Versions
-------

This library aims to support and is [tested against][travis] the following Ruby
versions:

* Ruby 1.9.3
* Ruby 2.0.0
* Ruby 2.1.2
* Ruby 2.2.0
* Ruby 2.3.1
* Ruby 2.4.0
* Ruby 2.5.0

*NOTE: if you need `retryable` to be running on Ruby 1.8 use gem versions prior to 3.0.0 release*

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions,
however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or
implementation, you may volunteer to be a maintainer.
