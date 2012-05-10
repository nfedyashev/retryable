require 'spec_helper'

describe 'retryable' do

  it "should retry on default exception" do
    Kernel.should_receive(:sleep).once.with(1)

    count_retryable(:tries => 2) { |tries, ex| raise StandardError if tries < 1 }
    @try_count.should == 2
  end

  it "should make another try if exception is covered by :on" do
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

  it "doesn't retry any exception if :on is empty list" do
    lambda do
      count_retryable(:on => []) { raise }
    end.should raise_error RuntimeError
    @try_count.should == 1
  end

  it "should catch an exception that matches the regex" do
    Kernel.should_receive(:sleep).once.with(1)
    count_retryable(:matching => /IO timeout/) { |c,e| raise "yo, IO timeout!" if c == 0 }
    @try_count.should == 2
  end

  it "should not catch an exception that doesn't match the regex" do
    should_not_receive :sleep
    lambda do
      count_retryable(:matching => /TimeError/) { raise "yo, IO timeout!" }
    end.should raise_error RuntimeError
    @try_count.should == 1
  end

  it "doesn't allow invalid options" do
    lambda do
      retryable(:bad_option => 2) { raise "this is bad" }
    end.should raise_error InvalidRetryableOptions
  end
  
end

describe 'retryable disabled' do
  
  around(:each) do |example|
    Retryable.disable!
    example.run
    Retryable.enable!
  end
  
  it "should not retry if disabled" do
    lambda do
      count_retryable(:tries => 2) { raise }
    end.should raise_error RuntimeError
    @try_count.should == 1
  end
  
end