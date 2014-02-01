require 'retryable/version'
require 'retryable/config'

module Kernel
  def retryable(options = {}, &block)
    opts = {:tries => 2, :sleep => 1, :on => StandardError, :matching  => /.*/, :ensure => Proc.new {}, :exception_cb => Proc.new {}}
    check_for_invalid_options(options, opts)
    opts.merge!(options)

    return if opts[:tries] == 0

    on_exception, tries = [ opts[:on] ].flatten, opts[:tries]
    retries = 0
    retry_exception = nil

    begin
      return yield retries, retry_exception
    rescue *on_exception => exception
      raise unless Retryable.enabled?
      raise unless exception.message =~ opts[:matching]
      raise if retries+1 >= opts[:tries]

      # Interrupt Exception could be raised while sleeping
      begin
        sleep opts[:sleep].respond_to?(:call) ? opts[:sleep].call(retries) : opts[:sleep]
      rescue *on_exception
      end

      retries += 1
      retry_exception = exception
      opts[:exception_cb].call(retry_exception)
      retry
    ensure
      opts[:ensure].call(retries)
    end
  end

  private

  def check_for_invalid_options(custom_options, default_options)
    invalid_options = default_options.merge(custom_options).keys - default_options.keys

    raise ArgumentError.new("[Retryable] Invalid options: #{invalid_options.join(", ")}") unless invalid_options.empty?
  end
end

