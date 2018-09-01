require 'spec_helper'
require 'timeout'

RSpec.describe Retryable do
  describe '.retryable' do
    before do
      described_class.enable
      expect(Kernel).to receive(:sleep)
    end

    let(:retryable) do
      -> { Retryable.retryable(tries: 2) { |tries| raise StandardError, "because foo" if tries < 1 } }
    end

    context 'given default configuration' do
      it 'does not output anything' do
        expect { retryable.call }.not_to output.to_stdout_from_any_process
      end
    end

    context 'given custom STDOUT logger config option' do
      it 'does not output anything' do
        described_class.configure do |config|
          config.log_method = lambda do |retries, exception|
             Logger.new(STDOUT).debug("[Attempt ##{retries}] Retrying because [#{exception.class} - #{exception.message}]: #{exception.backtrace.first(5).join(' | ')}")
          end
        end

        expect { retryable.call }.to output(/\[Attempt #1\] Retrying because \[StandardError - because foo\]/).to_stdout_from_any_process
      end
    end
  end
end

