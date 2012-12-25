require 'spec_helper'

describe Retryable do
  it 'is enabled by default' do
    Retryable.should be_enabled
  end

  it 'could be disabled' do
    Retryable.disable
    Retryable.should_not be_enabled
  end

  context 'when disabled' do
    before do
      Retryable.disable
    end

    it 'could be re-enabled' do
      Retryable.enable
      Retryable.should be_enabled
    end
  end
end
