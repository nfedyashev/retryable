require 'retryable'
require File.expand_path('../support/counter', __FILE__)

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include(Counter)

  config.before do
    Retryable.configuration = nil
  end
end
