require 'retryable/version'
require 'retryable/methods'

module Retryable
  extend Methods

  @enabled = true
  class << self; attr_accessor :enabled; end

  def self.enable
    @enabled = true
  end

  def self.disable
    @enabled = false
  end

  def self.enabled?
    !!@enabled
  end
end
