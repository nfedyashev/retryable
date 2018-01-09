require 'spec_helper'

RSpec.describe Retryable do
  describe '.with_context' do
    before do
      described_class.enable
      @attempt = 0
    end

    it 'properly checks context configuration' do
      expect do
        described_class.with_context(:foo) {}
      end.to raise_error ArgumentError, 'foo not found in Retryable.configuration.contexts. Available contexts: []'

      expect do
        described_class.retryable_with_context(:bar) {}
      end.to raise_error ArgumentError, 'bar not found in Retryable.configuration.contexts. Available contexts: []'

      expect do
        described_class.configure do |config|
          config.contexts[:faulty_service] = {
            sleep: 3
          }
        end

        described_class.retryable_with_context(:baz) {}
      end.to raise_error ArgumentError, 'baz not found in Retryable.configuration.contexts. Available contexts: [:faulty_service]'
    end

    it 'properly fetches context options' do
      allow(Kernel).to receive(:sleep)

      described_class.configure do |config|
        config.contexts[:faulty_service] = {
          tries: 3
        }
      end

      c = counter_with_context(:faulty_service) { |tries| raise StandardError if tries < 2 }
      expect(c.count).to eq(3)
    end

    it 'properly overrides context options with local arguments' do
      allow(Kernel).to receive(:sleep)

      described_class.configure do |config|
        config.contexts[:faulty_service] = {
          tries: 1
        }
      end

      c = counter_with_context(:faulty_service, tries: 3) { |tries| raise StandardError if tries < 2 }
      expect(c.count).to eq(3)
    end
  end
end
