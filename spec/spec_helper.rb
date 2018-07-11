require 'retryable'
require 'simplecov'

Dir.glob(File.expand_path('support/**/*.rb', __dir__), &method(:require))

SimpleCov.start

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include(Counter)

  config.before do
    Retryable.configuration = nil
  end
end
