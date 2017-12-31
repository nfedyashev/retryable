module Counter
  class Generator
    attr_reader :count

    def initialize(options)
      @options = options
      @count = 0
    end

    def around
      Retryable.retryable(@options) do |*arguments|
        increment
        yield(*arguments)
      end
    end

    private

    def increment
      @count += 1
    end
  end

  def counter(options = {}, &block)
    @counter ||= Generator.new(options)
    @counter.around(&block) if block_given?
    @counter
  end
end
