require 'spec_helper'

describe 'Kernel.retryable' do
  before(:each) do
    Retryable.enable
    @attempt = 0
  end

  it 'catch StandardError only by default' do
    lambda do
      count_retryable(:tries => 2) { |tries, ex| raise Exception if tries < 1 }
    end.should raise_error Exception
    @try_count.should == 1
  end

  it 'retries on default exception' do
    Kernel.should_receive(:sleep).once.with(1)

    count_retryable(:tries => 2) { |tries, ex| raise StandardError if tries < 1 }
    @try_count.should == 2
  end

  it 'does not retry if disabled' do
    Retryable.disable

    lambda do
      count_retryable(:tries => 2) { raise }
    end.should raise_error RuntimeError
    @try_count.should == 1
  end

  it 'executes *ensure* clause' do
    ensure_cb  = Proc.new do |retries|
      retries.should == 0
    end

    Kernel.retryable(:ensure => ensure_cb) { }
  end

  it 'passes retry count and exception on retry' do
    Kernel.should_receive(:sleep).once.with(1)

    count_retryable(:tries => 2) do |tries, ex|
      ex.class.should == StandardError if tries > 0
      raise StandardError if tries < 1
    end
    @try_count.should == 2
  end

  it 'makes another try if exception is covered by :on' do
    Kernel.stub(:sleep)
    count_retryable(:on => [StandardError, ArgumentError, RuntimeError] ) { |tries, ex| raise ArgumentError if tries < 1 }
    @try_count.should == 2
  end

  it 'does not try on unexpected exception' do
    Kernel.stub(:sleep)
    lambda do
      count_retryable(:on => RuntimeError ) { |tries, ex| raise StandardError if tries < 1 }
    end.should raise_error StandardError
    @try_count.should == 1
  end

  it 'retries three times' do
    Kernel.stub(:sleep)
    count_retryable(:tries => 3) { |tries, ex| raise StandardError if tries < 2 }
    @try_count.should == 3
  end

  it 'retries on default exception' do
    Kernel.should_receive(:sleep).once.with(1)

    count_retryable(:tries => 2) { |tries, ex| raise StandardError if tries < 1 }
    @try_count.should == 2
  end

  it 'executes exponential backoff scheme for :sleep option' do
    [1, 4, 16, 64].each { |i| Kernel.should_receive(:sleep).once.ordered.with(i) }
    lambda do
      Kernel.retryable(:tries => 5, :sleep => lambda { |n| 4**n }) { raise RangeError }
    end.should raise_error RangeError
  end

  it 'does not retry any exception if :on is empty list' do
    lambda do
      count_retryable(:on => []) { raise }
    end.should raise_error RuntimeError
    @try_count.should == 1
  end

  it 'catches an exception that matches the regex' do
    Kernel.should_receive(:sleep).once.with(1)
    count_retryable(:matching => /IO timeout/) { |c,e| raise "yo, IO timeout!" if c == 0 }
    @try_count.should == 2
  end

  it 'does not catch an exception that does not match the regex' do
    should_not_receive :sleep
    lambda do
      count_retryable(:matching => /TimeError/) { raise "yo, IO timeout!" }
    end.should raise_error RuntimeError
    @try_count.should == 1
  end

  it 'does not allow invalid options' do
    lambda do
      retryable(:bad_option => 2) { raise "this is bad" }
    end.should raise_error ArgumentError, '[Retryable] Invalid options: bad_option'
  end

  it 'accepts a callback to run after an exception is rescued' do
    lambda do
      retryable(:sleep => 0, :exception_cb => Proc.new {|e| @raised = e.to_s }) {|tries, ex| raise StandardError.new("this is fun!") if tries < 1 }
    end.should_not raise_error

    @raised.should == "this is fun!"
  end
end
