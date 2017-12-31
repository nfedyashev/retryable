module Retryable
  module Version
    MAJOR = 2
    MINOR = 0
    PATCH = 4

    module_function

    def to_a
      [MAJOR, MINOR, PATCH].compact
    end

    def to_s
      to_a.join('.')
    end
  end
end
