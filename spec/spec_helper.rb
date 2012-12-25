require File.dirname(__FILE__) + '/../lib/retryable'
require 'rspec'

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'

  def count_retryable(*opts)
    @try_count = 0
    return Kernel.retryable(*opts) do |*args|
      @try_count += 1
      yield *args
    end
  end
end
