require 'spec_helper'

# rubocop:disable RSpec/SpecFilePathFormat
RSpec.describe Retryable do
  it 'is enabled by default' do
    expect(described_class).to be_enabled
  end

  it 'could be disabled' do
    described_class.disable
    expect(described_class).not_to be_enabled
  end

  context 'when disabled' do
    before do
      described_class.disable
    end

    it 'could be re-enabled' do
      described_class.enable
      expect(described_class).to be_enabled
    end
  end

  context 'when configured locally' do
    it 'does not affect the original global config' do
      new_sleep = 2
      original_sleep = described_class.configuration.send(:sleep)

      expect(original_sleep).not_to eq(new_sleep)

      counter(tries: 2, sleep: new_sleep) do |tries, _ex|
        raise StandardError if tries < 1
      end

      actual = described_class.configuration.send(:sleep)
      expect(actual).to eq(original_sleep)
    end
  end

  context 'when configured globally with custom sleep parameter' do
    it 'passes retry count and exception on retry' do
      expect(Kernel).to receive(:sleep).once.with(3)

      described_class.configure do |config|
        config.sleep = 3
      end

      counter(tries: 2) do |tries, ex|
        expect(ex.class).to eq(StandardError) if tries > 0
        raise StandardError if tries < 1
      end
      expect(counter.count).to eq(2)
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
