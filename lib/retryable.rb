# Code originally by Chu Yeow, see 
# http://blog.codefront.net/2008/01/14/retrying-code-blocks-in-ruby-on-exceptions-whatever/
# Slightly rewritten to allow for passing of more than just type of exception.

def retryable(options = {}, &block)
  opts = { :tries => 1, :on => Exception }.merge(options)

  return nil if opts[:tries] == 0

  retry_exception, tries = [ opts[:on] ].flatten, opts[:tries]

  begin
    return yield
  rescue *retry_exception
    retry if (tries -= 1) > 0
  end

  yield
end
