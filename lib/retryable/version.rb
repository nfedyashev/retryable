module Retryable
  # This module holds the Retryable version information.
  module Version
    module_function

    # @return [Integer]
    def major
      3
    end

    # @return [Integer]
    def minor
      0
    end

    # @return [Integer]
    def patch
      1
    end

    # @return [Hash]
    def to_h
      {
        major: major,
        minor: minor,
        patch: patch
      }
    end

    # @return [Hash]
    def to_a
      [major, minor, patch].compact
    end

    # @return [String]
    def to_s
      to_a.join('.')
    end
  end
end
