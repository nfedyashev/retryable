require 'spec_helper'

describe Retryable::Version do
  subject { Retryable::Version.to_s }

  it { should == '1.3.5' }
end
