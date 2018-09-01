module Retryable
  # Used to set up and modify settings for the retryable.
  class Configuration
    VALID_OPTION_KEYS = [
      :contexts,
      :ensure,
      :exception_cb,
      :log_method,
      :matching,
      :not,
      :on,
      :sleep,
      :sleep_method,
      :tries
    ].freeze

    attr_accessor(*VALID_OPTION_KEYS)

    attr_accessor :enabled

    def initialize
      @contexts     = {}
      @ensure       = proc {}
      @exception_cb = proc {}
      @log_method   = proc {}
      @matching     = /.*/
      @not          = []
      @on           = StandardError
      @sleep        = 1
      @sleep_method = ->(seconds) { Kernel.sleep(seconds) }
      @tries        = 2

      @enabled      = true
    end

    def enable
      @enabled = true
    end
    alias enabled? enabled

    def disable
      @enabled = false
    end

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    def [](option)
      send(option)
    end

    # Returns a hash of all configurable options
    def to_hash
      VALID_OPTION_KEYS.each_with_object({}) do |key, memo|
        memo[key] = instance_variable_get("@#{key}")
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
