
module Kernel
  class InvalidRetryableOptions < RuntimeError; end

  def retryable(options = {}, &block)
    opts = { :tries => 2, :sleep => 1, :on => StandardError, :matching  => /.*/ }
    check_for_invalid_options(options, opts)
    opts.merge!(options)

    return nil if opts[:tries] == 0

    on_exception, tries = [ opts[:on] ].flatten, opts[:tries]
    retries = 0
    retry_exception = nil
    
    begin
      return yield retries, retry_exception
    rescue *on_exception => exception
      raise unless exception.message =~ opts[:matching]
      raise if retries+1 >= opts[:tries]
      sleep opts[:sleep].respond_to?(:call) ? opts[:sleep].call(retries) : opts[:sleep]
      retries += 1
      retry_exception = exception
      retry
    end
  end

  private

  def check_for_invalid_options(custom_options, default_options)
    invalid_options = default_options.merge(custom_options).keys - default_options.keys
    raise InvalidRetryableOptions.new("Invalid options: #{invalid_options.join(", ")}") unless invalid_options.empty?
  end
end
