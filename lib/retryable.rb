require 'retryable/version'
require 'retryable/config'

module Retryable
  # Used to set up and modify settings for the retryable.
  class Configuration
    OPTIONS = [
      :ensure,
      :exception_cb,
      :matching,
      :on,
      :sleep,
      :tries
    ].freeze

    attr_accessor :ensure
    attr_accessor :exception_cb
    attr_accessor :matching
    attr_accessor :on
    attr_accessor :sleep
    attr_accessor :tries

    #alias_method :test_mode?, :test_mode

    def initialize
      @ensure       = Proc.new {}
      @exception_cb = Proc.new {}
      @matching     = /.*/
      @on           = StandardError
      @sleep        = 1
      @tries        = 2
    end

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    def [](option)
      send(option)
    end

    # Returns a hash of all configurable options
    def to_hash
      OPTIONS.inject({}) do |hash, option|
        hash[option.to_sym] = self.send(option)
        hash
      end
    end

    # Returns a hash of all configurable options merged with +hash+
    #
    # @param [Hash] hash A set of configuration options that will take precedence over the defaults
    def merge(hash)
      to_hash.merge(hash)
    end
  end
end

module Retryable
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
  #   end
  def self.configure
    yield(configuration)
  end

  # The configuration object.
  # @see Retryable.configure
  def self.configuration
    @configuration ||= Configuration.new
  end

  class << self
    # A Retryable configuration object. Must act like a hash and return sensible
    # values for all Retryable configuration options. See Retryable::Configuration.
    attr_writer :configuration
  end

  def self.retryable(options = {}, &block)
    opts = {
      :tries        => self.configuration.tries,
      :sleep        => self.configuration.sleep,
      :on           => self.configuration.on,
      :matching     => self.configuration.matching,
      :ensure       => self.configuration.ensure,
      :exception_cb => self.configuration.exception_cb
    }

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
      raise if retries+1 >= tries

      # Interrupt Exception could be raised while sleeping
      begin
        Kernel.sleep opts[:sleep].respond_to?(:call) ? opts[:sleep].call(retries) : opts[:sleep]
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

  def self.check_for_invalid_options(custom_options, default_options)
    invalid_options = default_options.merge(custom_options).keys - default_options.keys

    raise ArgumentError.new("[Retryable] Invalid options: #{invalid_options.join(", ")}") unless invalid_options.empty?
  end
end

