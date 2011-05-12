
module Kernel
  def retryable(options = {}, &block)
    opts = { :tries => 2, :sleep => 1, :on => Exception }.merge(options)

    return nil if opts[:tries] == 0

    retry_exception, tries = [ opts[:on] ].flatten, opts[:tries]
    retries = 0

    begin
      return yield retries
    rescue *retry_exception
      raise if retries+1 >= opts[:tries]
      sleep opts[:sleep].respond_to?(:call) ? opts[:sleep].call(retries) : opts[:sleep]
      retries += 1
      retry
    end
  end
end
