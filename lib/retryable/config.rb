require 'singleton'

module Retryable
  class Config
    include Singleton
    attr_accessor :allow_retry
  end
  
  def self.enable!
    Config.instance.allow_retry = true
  end
  
  def self.disable!
    Config.instance.allow_retry = false
  end
end

# Set defaults
Retryable.enable!