require 'retryable'

# rubocop:disable Style/ExpandPathArguments
Dir.glob(File.expand_path('../support/**/*.rb', __FILE__), &method(:require))
# rubocop:enable Style/ExpandPathArguments

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include(Counter)

  config.before do
    Retryable.configuration = nil
  end
end
