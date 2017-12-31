require 'retryable'
require 'simplecov'
require 'pry'

Dir.glob(File.expand_path('../support/**/*.rb', __FILE__), &method(:require))

SimpleCov.start

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include(Counter)

  config.before do
    Retryable.configuration = nil
  end
end
