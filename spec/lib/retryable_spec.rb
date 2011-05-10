require 'spec_helper'

describe 'retryable' do

  before(:each) do
    @attempt = 0
  end

  it "should make another try on exception" do
    retryable(:tries => 1, :on => RuntimeError) do
      @attempt = @attempt + 1
      raise RuntimeError unless @attempt == 2
    end
  end

  it "should make another try if exception is in whitelist" do
    retryable(:tries => 1, :on => [StandardError, ArgumentError, RuntimeError]) do
      @attempt = @attempt + 1
      raise ArgumentError unless @attempt == 2
    end
  end

  it "should not try on unexpected exception" do
    lambda do
      retryable(:tries => 1, :on => RuntimeError) do
        @attempt = @attempt + 1
        raise StandardError unless @attempt == 2
      end
    end.should raise_error StandardError
  end

  it "should make always retry on default exception" do
    retryable(:tries => 1) do
      @attempt = @attempt + 1
      raise StandardError unless @attempt == 2
    end
  end

  it "should retry once unless :tries explicitly set" do
    retryable do
      @attempt = @attempt + 1
      raise StandardError unless @attempt == 2
    end
  end

  it "should retry twice" do
    retryable(:tries => 2, :on => RuntimeError) do
      @attempt = @attempt + 1
      raise RuntimeError unless @attempt == 3
    end
  end

end
