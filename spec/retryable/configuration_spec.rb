require 'spec_helper'

RSpec.describe Retryable do
  it 'is enabled by default' do
    expect(Retryable).to be_enabled
  end

  it 'could be disabled' do
    Retryable.disable
    expect(Retryable).not_to be_enabled
  end

  context 'when disabled' do
    before do
      Retryable.disable
    end

    it 'could be re-enabled' do
      Retryable.enable
      expect(Retryable).to be_enabled
    end
  end

  context 'when configured globally with custom sleep parameter' do
    it 'passes retry count and exception on retry' do
      expect(Kernel).to receive(:sleep).once.with(3)

      Retryable.configure do |config|
        config.sleep = 3
      end

      count_retryable(:tries => 2) do |tries, ex|
        expect(ex.class).to eq(StandardError) if tries > 0
        raise StandardError if tries < 1
      end
      expect(@try_count).to eq(2)
    end
  end
end
