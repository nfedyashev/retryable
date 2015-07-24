module Retryable
  # Used to set up and modify settings for the retryable.
  class Configuration
    OPTIONS = [
      :ensure,
      :exception_cb,
      :matching,
      :on,
      :sleep,
      :tries,
      :not
    ].freeze

    attr_accessor :ensure
    attr_accessor :exception_cb
    attr_accessor :matching
    attr_accessor :on
    attr_accessor :sleep
    attr_accessor :tries
    attr_accessor :not

    attr_accessor :enabled

    alias_method :enabled?, :enabled

    def initialize
      @ensure       = Proc.new {}
      @exception_cb = Proc.new {}
      @matching     = /.*/
      @on           = StandardError
      @sleep        = 1
      @tries        = 2
      @not          = []

      @enabled     = true
    end

    def enable
      @enabled = true
    end

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
