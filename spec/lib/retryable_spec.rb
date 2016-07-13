require 'spec_helper'

RSpec.describe 'Retryable.retryable' do
  before(:each) do
    Retryable.enable
    @attempt = 0
  end

  it 'catch StandardError only by default' do
    expect do
      count_retryable(:tries => 2) { |tries, ex| raise Exception if tries < 1 }
    end.to raise_error Exception
    expect(@try_count).to eq(1)
  end

  it 'retries on default exception' do
    expect(Kernel).to receive(:sleep).once.with(1)

    count_retryable(:tries => 2) { |tries, ex| raise StandardError if tries < 1 }
    expect(@try_count).to eq(2)
  end

  it 'does not retry if disabled' do
    Retryable.disable

    expect do
      count_retryable(:tries => 2) { raise }
    end.to raise_error RuntimeError
    expect(@try_count).to eq(1)
  end

  it 'executes *ensure* clause' do
    ensure_cb  = Proc.new do |retries|
      expect(retries).to eq(0)
    end

    Retryable.retryable(:ensure => ensure_cb) { }
  end

  it 'passes retry count and exception on retry' do
    expect(Kernel).to receive(:sleep).once.with(1)

    count_retryable(:tries => 2) do |tries, ex|
      expect(ex.class).to eq(StandardError) if tries > 0
      raise StandardError if tries < 1
    end
    expect(@try_count).to eq(2)
  end

  it 'makes another try if exception is covered by :on' do
    allow(Kernel).to receive(:sleep)
    count_retryable(:on => [StandardError, ArgumentError, RuntimeError] ) { |tries, ex| raise ArgumentError if tries < 1 }
    expect(@try_count).to eq(2)
  end

  it 'does not try on unexpected exception' do
    allow(Kernel).to receive(:sleep)
    expect do
      count_retryable(:on => RuntimeError ) { |tries, ex| raise StandardError if tries < 1 }
    end.to raise_error StandardError
    expect(@try_count).to eq(1)
  end

  it 'retries three times' do
    allow(Kernel).to receive(:sleep)
    count_retryable(:tries => 3) { |tries, ex| raise StandardError if tries < 2 }
    expect(@try_count).to eq(3)
  end

  it 'retries infinitely' do
    expect do
      Timeout::timeout(3) do
        count_retryable(:tries => :infinite, :sleep => 0.1) { |tries, ex| raise StandardError }
      end
    end.to raise_error Timeout::Error

    expect(@try_count).to be > 10
  end

  it 'retries on default exception' do
    expect(Kernel).to receive(:sleep).once.with(1)

    count_retryable(:tries => 2) { |tries, ex| raise StandardError if tries < 1 }
    expect(@try_count).to eq(2)
  end

  it 'executes exponential backoff scheme for :sleep option' do
    [1, 4, 16, 64].each { |i| expect(Kernel).to receive(:sleep).once.ordered.with(i) }
    expect do
      Retryable.retryable(:tries => 5, :sleep => lambda { |n| 4**n }) { raise RangeError }
    end.to raise_error RangeError
  end

  it 'calls :sleep_method option' do
    sleep_method = double
    expect(sleep_method).to receive(:call).twice
    expect do
      Retryable.retryable(:tries => 3, :sleep_method => sleep_method) { |tries| raise RangeError if tries < 3}
    end.to raise_error RangeError
  end

  it 'does not retry any exception if :on is empty list' do
    expect do
      count_retryable(:on => []) { raise }
    end.to raise_error RuntimeError
    expect(@try_count).to eq(1)
  end

  it 'catches an exception that matches the regex' do
    expect(Kernel).to receive(:sleep).once.with(1)
    count_retryable(:matching => /IO timeout/) { |c,e| raise "yo, IO timeout!" if c == 0 }
    expect(@try_count).to eq(2)
  end

  it 'does not catch an exception that does not match the regex' do
    expect(Kernel).not_to receive(:sleep)
    expect do
      count_retryable(:matching => /TimeError/) { raise "yo, IO timeout!" }
    end.to raise_error RuntimeError
    expect(@try_count).to eq(1)
  end

  it 'does not allow invalid options' do
    expect do
      Retryable.retryable(:bad_option => 2) { raise "this is bad" }
    end.to raise_error ArgumentError, '[Retryable] Invalid options: bad_option'
  end

  it 'accepts a callback to run after an exception is rescued' do
    expect do
      Retryable.retryable(:sleep => 0, :exception_cb => Proc.new {|e| @raised = e.to_s }) {|tries, ex| raise StandardError.new("this is fun!") if tries < 1 }
    end.not_to raise_error

    expect(@raised).to eq("this is fun!")
  end

  it 'does not retry on :not exception' do
    expect do
      count_retryable(:not => RuntimeError ) { |tries, ex| raise RuntimeError if tries < 1 }
    end.to raise_error RuntimeError
    expect(@try_count).to eq(1)
  end

  it 'gives precidence for :not over :on' do
    expect do
      count_retryable(:sleep => 0, :tries => 3, :on => StandardError, :not => IndexError ) { |tries, ex| raise tries >= 1 ? IndexError : StandardError }
    end.to raise_error IndexError
    expect(@try_count).to eq(2)
  end
end
