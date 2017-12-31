require 'retryable'
require 'pry'

Dir.glob(File.expand_path('../support/**/*.rb', __FILE__), &method(:require))

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include(Counter)

  config.before do
    Retryable.configuration = nil
  end
end
