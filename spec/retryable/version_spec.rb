require 'spec_helper'

RSpec.describe Retryable::Version do
  before do
    allow(described_class).to receive_messages(
      major: 2,
      minor: 0,
      patch: 4
    )
  end

  describe '.to_h' do
    it 'returns a hash with the right values' do
      expect(described_class.to_h).to be_a Hash
      expect(described_class.to_h[:major]).to eq(2)
      expect(described_class.to_h[:minor]).to eq(0)
      expect(described_class.to_h[:patch]).to eq(4)
    end
  end

  describe '.to_a' do
    it 'returns an array with the right values' do
      expect(described_class.to_a).to be_an Array
      expect(described_class.to_a).to eq([2, 0, 4])
    end
  end

  describe '.to_s' do
    it 'returns a string with the right value' do
      expect(described_class.to_s).to be_a String
      expect(described_class.to_s).to eq('2.0.4')
    end
  end
end
