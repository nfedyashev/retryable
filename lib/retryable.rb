require 'retryable/version'
require 'retryable/configuration'

module Retryable
  class << self
    # A Retryable configuration object. Must act like a hash and return sensible
    # values for all Retryable configuration options. See Retryable::Configuration.
    attr_writer :configuration

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   Retryable.configure do |config|
    #     config.ensure       = Proc.new {}
    #     config.exception_cb = Proc.new {}
    #     config.matching     = /.*/
    #     config.on           = StandardError
    #     config.sleep        = 1
    #     config.tries        = 2
    #     config.not          = []
    #   end
    def configure
      yield(configuration)
    end

    # The configuration object.
    # @see Retryable.configure
    def configuration
      @configuration ||= Configuration.new
    end

    def enabled?
      configuration.enabled?
    end

    def enable
      configuration.enable
    end

    def disable
      configuration.disable
    end

    def retryable(options = {}, &block)
      opts = {
        :tries        => self.configuration.tries,
        :sleep        => self.configuration.sleep,
        :on           => self.configuration.on,
        :matching     => self.configuration.matching,
        :ensure       => self.configuration.ensure,
        :exception_cb => self.configuration.exception_cb,
        :not          => self.configuration.not
      }

      check_for_invalid_options(options, opts)
      opts.merge!(options)

      return if opts[:tries] == 0

      on_exception = [ opts[:on] ].flatten
      not_exception = [ opts[:not] ].flatten
      tries = opts[:tries]
      retries = 0
      retry_exception = nil

      begin
        return yield retries, retry_exception
      rescue *not_exception
        raise
      rescue *on_exception => exception
        raise unless configuration.enabled?
        raise unless exception.message =~ opts[:matching]
        raise if retries+1 >= tries

        # Interrupt Exception could be raised while sleeping
        begin
          Kernel.sleep opts[:sleep].respond_to?(:call) ? opts[:sleep].call(retries) : opts[:sleep]
        rescue *not_exception
          raise
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
end
