module Retryable
  class Version
    MAJOR = 2 unless defined? Retryable::Version::MAJOR
    MINOR = 0 unless defined? Retryable::Version::MINOR
    PATCH = 2 unless defined? Retryable::Version::PATCH

    class << self

      # @return [String]
      def to_s
        [MAJOR, MINOR, PATCH].compact.join('.')
      end

    end
  end
end
