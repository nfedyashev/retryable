require 'spec_helper'

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
