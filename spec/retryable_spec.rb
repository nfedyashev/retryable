require 'spec_helper'
require 'timeout'

RSpec.describe Retryable do
  describe '.retryable' do
    before do
      described_class.enable
      @attempt = 0
    end

    it 'catch StandardError only by default' do
      expect do
        counter(tries: 2) { |tries| raise Exception if tries < 1 }
      end.to raise_error Exception
      expect(counter.count).to eq(1)
    end

    it 'retries on default exception' do
      expect(Kernel).to receive(:sleep).once.with(1)

      counter(tries: 2) { |tries| raise StandardError if tries < 1 }
      expect(counter.count).to eq(2)
    end

    it 'does not retry if disabled' do
      described_class.disable

      expect do
        counter(tries: 2) { raise }
      end.to raise_error RuntimeError
      expect(counter.count).to eq(1)
    end

    it 'executes *ensure* clause' do
      ensure_cb = proc do |retries|
        expect(retries).to eq(0)
      end

      described_class.retryable(ensure: ensure_cb) {}
    end

    it 'passes retry count and exception on retry' do
      expect(Kernel).to receive(:sleep).once.with(1)

      counter(tries: 2) do |tries, ex|
        expect(ex.class).to eq(StandardError) if tries > 0
        raise StandardError if tries < 1
      end
      expect(counter.count).to eq(2)
    end

    it 'makes another try if exception is covered by :on' do
      allow(Kernel).to receive(:sleep)
      counter(on: [StandardError, ArgumentError, RuntimeError]) do |tries|
        raise ArgumentError if tries < 1
      end
      expect(counter.count).to eq(2)
    end

    it 'does not retry on :not exception which is covered by Array' do
      expect do
        counter(not: [RuntimeError, IndexError]) { |tries| raise RuntimeError if tries < 1 }
      end.to raise_error RuntimeError
      expect(counter.count).to eq(1)
    end

    it 'does not try on unexpected exception' do
      allow(Kernel).to receive(:sleep)
      expect do
        counter(on: RuntimeError) { |tries| raise StandardError if tries < 1 }
      end.to raise_error StandardError
      expect(counter.count).to eq(1)
    end

    it 'tries three times when "tries" option is set to 3' do
      allow(Kernel).to receive(:sleep)
      counter(tries: 3) { |tries| raise StandardError if tries < 2 }
      expect(counter.count).to eq(3)
    end

    it 'tries four times when "retries" option is set to 3' do
      allow(Kernel).to receive(:sleep)
      counter(retries: 3) { |tries| raise StandardError if tries < 3 }
      expect(counter.count).to eq(4)
    end

    context 'infinite retries' do
      example 'with magic constant' do
        expect do
          Timeout.timeout(3) do
            counter(tries: :infinite, sleep: 0.1) { raise StandardError }
          end
        end.to raise_error Timeout::Error

        expect(counter.count).to be > 10
      end

      example 'with native infinity data type' do
        expect do
          require 'bigdecimal'

          tries = [Float::INFINITY, BigDecimal::INFINITY, BigDecimal("1.0") / BigDecimal("0.0")]
          Timeout.timeout(3) do
            counter(tries: tries.sample, sleep: 0.1) { raise StandardError }
          end
        end.to raise_error Timeout::Error

        expect(counter.count).to be > 10
      end
    end

    it 'executes exponential backoff scheme for :sleep option' do
      [1, 4, 16, 64].each { |i| expect(Kernel).to receive(:sleep).once.ordered.with(i) }
      expect do
        described_class.retryable(tries: 5, sleep: ->(n) { 4**n }) { raise RangeError }
      end.to raise_error RangeError
    end

    it 'calls :sleep_method option' do
      sleep_method = double
      expect(sleep_method).to receive(:call).twice
      expect do
        described_class.retryable(tries: 3, sleep_method: sleep_method) { |tries| raise RangeError if tries < 9 }
      end.to raise_error RangeError
    end

    it 'does not retry any exception if :on is empty list' do
      expect do
        counter(on: []) { raise }
      end.to raise_error RuntimeError
      expect(counter.count).to eq(1)
    end

    it 'catches an exception that matches the regex' do
      expect(Kernel).to receive(:sleep).once.with(1)
      counter(matching: /IO timeout/) { |c, _e| raise 'yo, IO timeout!' if c == 0 }
      expect(counter.count).to eq(2)
    end

    it 'does not catch an exception that does not match the regex' do
      expect(Kernel).not_to receive(:sleep)
      expect do
        counter(matching: /TimeError/) { raise 'yo, IO timeout!' }
      end.to raise_error RuntimeError
      expect(counter.count).to eq(1)
    end

    it 'catches an exception in the list of matches' do
      expect(Kernel).to receive(:sleep).once.with(1)
      counter(matching: [/IO timeout/, 'IO tymeout']) { |c, _e| raise 'yo, IO timeout!' if c == 0 }
      expect(counter.count).to eq(2)

      expect(Kernel).to receive(:sleep).once.with(1)
      counter(matching: [/IO timeout/, 'IO tymeout']) { |c, _e| raise 'yo, IO tymeout!' if c == 0 }
      expect(counter.count).to eq(4)
    end

    it 'does not allow invalid type of matching option' do
      expect do
        described_class.retryable(matching: 1) { raise 'this is invaid type of matching iotion' }
      end.to raise_error ArgumentError, ':matching must be a string or regex'
    end

    it 'does not allow invalid options' do
      expect do
        described_class.retryable(bad_option: 2) { raise 'this is bad' }
      end.to raise_error ArgumentError, '[Retryable] Invalid options: bad_option'
    end

    # rubocop:disable Rspec/InstanceVariable
    it 'accepts a callback to run after an exception is rescued' do
      expect do
        described_class.retryable(sleep: 0, exception_cb: proc { |e| @raised = e.to_s }) do |tries|
          raise StandardError, 'this is fun!' if tries < 1
        end
      end.not_to raise_error

      expect(@raised).to eq('this is fun!')
    end
    # rubocop:enable Rspec/InstanceVariable

    it 'does not retry on :not exception' do
      expect do
        counter(not: RuntimeError) { |tries| raise RuntimeError if tries < 1 }
      end.to raise_error RuntimeError
      expect(counter.count).to eq(1)
    end

    it 'gives precidence for :not over :on' do
      expect do
        counter(sleep: 0, tries: 3, on: StandardError, not: IndexError) do |tries|
          raise tries >= 1 ? IndexError : StandardError
        end
      end.to raise_error IndexError
      expect(counter.count).to eq(2)
    end
  end
end
