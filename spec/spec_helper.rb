require 'retryable'
require 'simplecov'

# rubocop:disable Style/ExpandPathArguments
Dir.glob(File.expand_path('../support/**/*.rb', __FILE__), &method(:require))
# rubocop:enable Style/ExpandPathArguments

if ENV['CI']
  require 'simplecov_json_formatter'
  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
end

SimpleCov.start

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include(Counter)

  config.before do
    Retryable.configuration = nil
  end
end
