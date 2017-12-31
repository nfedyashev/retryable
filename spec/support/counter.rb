module Counter
  class Counter
    attr_reader :count

    def initialize(options)
      @options = options
      @count = 0
    end

    def around
      Retryable.retryable(@options) do |*arguments|
        @count += 1
        yield(*arguments)
      end
    end
  end

  def counter(options = {})
    @counter ||= Counter.new(options)
  end
end
