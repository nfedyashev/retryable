require 'retryable'

module Kernel
  extend Retryable::Methods
end

include Retryable::Methods
