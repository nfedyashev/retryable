module Retryable
  class Version
    MAJOR = 1 unless defined? Retryable::Version::MAJOR
    MINOR = 3 unless defined? Retryable::Version::MINOR
    PATCH = 5 unless defined? Retryable::Version::PATCH

    class << self

      # @return [String]
      def to_s
        [MAJOR, MINOR, PATCH].compact.join('.')
      end

    end
  end
end
