module Retryable
  class Version
    MAJOR = 1 unless defined? Twitter::Version::MAJOR
    MINOR = 3 unless defined? Twitter::Version::MINOR
    PATCH = 2 unless defined? Twitter::Version::PATCH

    class << self

      # @return [String]
      def to_s
        [MAJOR, MINOR, PATCH].compact.join('.')
      end

    end
  end
end
