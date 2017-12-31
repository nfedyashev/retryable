require 'spec_helper'

RSpec.describe Retryable::Version do
  before do
    allow(Retryable::Version).to receive(:major).and_return(2)
    allow(Retryable::Version).to receive(:minor).and_return(0)
    allow(Retryable::Version).to receive(:patch).and_return(4)
  end

  describe '.to_h' do
    it 'returns a hash with the right values' do
      expect(Retryable::Version.to_h).to be_a Hash
      expect(Retryable::Version.to_h[:major]).to eq(2)
      expect(Retryable::Version.to_h[:minor]).to eq(0)
      expect(Retryable::Version.to_h[:patch]).to eq(4)
    end
  end

  describe '.to_a' do
    it 'returns an array with the right values' do
      expect(Retryable::Version.to_a).to be_an Array
      expect(Retryable::Version.to_a).to eq([2, 0, 4])
    end
  end

  describe '.to_s' do
    it 'returns a string with the right value' do
      expect(Retryable::Version.to_s).to be_a String
      expect(Retryable::Version.to_s).to eq('2.0.4')
    end
  end
end
