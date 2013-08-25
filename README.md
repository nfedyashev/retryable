retryable gem
=====

[![Build Status](https://travis-ci.org/nfedyashev/retryable.png?branch=master)](https://travis-ci.org/nfedyashev/retryable)

Description
--------

Runs a code block, and retries it when an exception occurs. It's great when
working with flakey webservices (for example).

It's configured using four optional parameters `:tries`, `:on`, `:sleep`, `:matching`, `:ensure` and
runs the passed block. Should an exception occur, it'll retry for (n-1) times.

Should the number of retries be reached without success, the last exception
will be raised.


Examples
--------

Open an URL, retry up to two times when an `OpenURI::HTTPError` occurs.

``` ruby
require "open-uri"

retryable(:tries => 3, :on => OpenURI::HTTPError) do
  xml = open("http://example.com/test.xml").read
end
```

Do _something_, retry up to four times for either `ArgumentError` or 
`TimeoutError` exceptions.

``` ruby
retryable(:tries => 5, :on => [ArgumentError, TimeoutError]) do
  # some crazy code
end
```

Run a block of code when the number of tries runs out.

``` ruby
finally_cb = Proc.new do |exception, retries|
  log "#{exception.class} raised too many times. Total number of attempts: #{retries + 1}"
end

retryable(:finally => finally_cb) do
  # code here...
end
```

Run a block of retryable code without raising an exception at all.

``` ruby
retryable(:raise => false) do
  # code here...
end


Ensure that block of code is executed, regardless of whether an exception was raised. It doesn't matter if the block exits normally, if it retries to execute block of code, or if it is terminated by an uncaught exception -- the ensure block will get run.

``` ruby
f = File.open("testfile")

ensure_cb = Proc.new do |retries|
  puts "total retry attempts: #{retries}"

  f.close
end

retryable(:ensure => ensure_cb) do
  # process file
end
```

## Defaults

    :tries => 2, :on => StandardError, :sleep => 1, :matching  => /.*/, :ensure => Proc.new { }, :finally => Proc.new { }, :raise => true

Sleeping
--------
By default Retryable waits for one second between retries. You can change this and even provide your own exponential backoff scheme.

```
retryable(:sleep => 0) { }                # don't pause at all between retries
retryable(:sleep => 10) { }               # sleep ten seconds between retries
retryable(:sleep => lambda { |n| 4**n }) { }   # sleep 1, 4, 16, etc. each try
```    

Matching error messages
--------
You can also retry based on the exception message:

```
retryable(:matching => /IO timeout/) do |retries, exception|
  raise "yo, IO timeout!" if retries == 0
end
```

Block Parameters
--------
Your block is called with two optional parameters: the number of tries until now, and the most recent exception.

```
retryable do |retries, exception|
  puts "try #{retries} failed with exception: #{exception}" if retries > 0
  pick_up_soap
end
```

You can temporary disable retryable blocks
--------

```
Retryble.enabled?
=> true

Retryble.disable

Retryble.enabled?
=> false
```

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

