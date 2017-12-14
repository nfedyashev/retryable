module Retryable
  # Used to set up and modify settings for the retryable.
  class Configuration
    VALID_OPTION_KEYS = [
      :ensure,
      :exception_cb,
      :matching,
      :on,
      :sleep,
      :tries,
      :not,
      :sleep_method
    ].freeze

    attr_accessor(*VALID_OPTION_KEYS)

    attr_accessor :enabled

    def initialize
      @ensure       = proc {}
      @exception_cb = proc {}
      @matching     = /.*/
      @on           = StandardError
      @sleep        = 1
      @tries        = 2
      @not          = []
      @sleep_method = lambda { |seconds| Kernel.sleep(seconds) }
      @enabled = true
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
