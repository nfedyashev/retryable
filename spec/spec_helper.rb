require File.dirname(__FILE__) + '/../lib/retryable'
require 'rspec'

RSpec.configure do |config|
  config.disable_monkey_patching!

  def count_retryable(*opts)
    @try_count = 0
    return Retryable.retryable(*opts) do |*args|
      @try_count += 1
      yield *args
    end
  end
end
