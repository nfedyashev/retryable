retryable gem
=====

![travis-ci](http://travis-ci.org/nfedyashev/retryable.png)

Description
--------

Runs a code block, and retries it when an exception occurs. It's great when
working with flakey webservices (for example).

It's configured using two optional parameters --`:tries` and `:on`--, and
runs the passed block. Should an exception occur, it'll retry for (n-1) times.

Should the number of retries be reached without success, the last exception
will be raised.


Examples
--------

Open an URL, retry up to two times when an `OpenURI::HTTPError` occurs.

``` ruby
require "retryable"
require "open-uri"

retryable( :tries => 3, :on => OpenURI::HTTPError ) do
  xml = open( "http://example.com/test.xml" ).read
end
```

Do _something_, retry up to four times for either `ArgumentError` or 
`TimeoutError` exceptions.

``` ruby
require "retryable"

retryable( :tries => 5, :on => [ ArgumentError, TimeoutError ] ) do
  # some crazy code
end
```

## Defaults

    :tries => 1, :on => Exception
    
  
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


## Changelog

*  v1.3: stability -- Thoroughly unit-tested
*  v1.2: FIX -- block would run twice when `:tries` was set to `0`. (Thanks for the heads-up to [Tuker](http://github.com/tuker).)


## Thanks

Many thanks to [Chu Yeow for this nifty piece of code](http://blog.codefront.net/2008/01/14/retrying-code-blocks-in-ruby-on-exceptions-whatever/). Look, I liked it
enough to enhance it a little bit and build a gem from it! :)

