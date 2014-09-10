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
end
