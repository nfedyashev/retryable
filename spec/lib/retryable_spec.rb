require 'spec_helper'

describe 'retryable' do

  before(:each) do
    @attempt = 0
  end

  it "should retry on default exception" do
    Kernel.should_receive(:sleep).once.with(1)

    count_retryable(:tries => 2) { |tries, ex| raise StandardError if tries < 1 }
    @try_count.should == 2
  end

  it "should make another try if exception is in whitelist" do
    Kernel.stub!(:sleep)
    count_retryable(:on => [StandardError, ArgumentError, RuntimeError] ) { |tries, ex| raise ArgumentError if tries < 1 }
    @try_count.should == 2
  end

  it "should not try on unexpected exception" do
    Kernel.stub!(:sleep)
    lambda do
      count_retryable(:on => RuntimeError ) { |tries, ex| raise StandardError if tries < 1 }
    end.should raise_error StandardError
    @try_count.should == 1
  end

  it "should three times" do
    Kernel.stub!(:sleep)
    count_retryable(:tries => 3) { |tries, ex| raise StandardError if tries < 2 }
    @try_count.should == 3
  end

  it "should retry on default exception" do
    Kernel.should_receive(:sleep).once.with(1)

    count_retryable(:tries => 2) { |tries, ex| raise StandardError if tries < 1 }
    @try_count.should == 2
  end

  it "exponential backoff scheme for :sleep option" do
    [1, 4, 16, 64].each { |i| Kernel.should_receive(:sleep).once.ordered.with(i) }
    lambda do
      Kernel.retryable(:tries => 5, :sleep => lambda { |n| 4**n }) { raise RangeError }
    end.should raise_error RangeError
  end

  #retryable(:sleep => lambda { |n| 4**n }) { }   # sleep 1, 4, 16, etc. each try
  private

  def count_retryable *opts
    @try_count = 0
    return Kernel.retryable(*opts) do |*args|
      @try_count += 1
      yield *args
    end
  end
end
