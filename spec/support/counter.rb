module Counter
  class PlainGenerator
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

  class GeneratorWithContext
    attr_reader :count

    def initialize(context_key, options)
      @context_key = context_key
      @count = 0
      @options = options
    end

    def around
      Retryable.with_context(@context_key, @options) do |*arguments|
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
    @counter ||= PlainGenerator.new(options)
    @counter.around(&block) if block_given?
    @counter
  end

  def counter_with_context(context_key, options = {}, &block)
    @counter_with_context ||= GeneratorWithContext.new(context_key, options)
    @counter_with_context.around(&block) if block_given?
    @counter_with_context
  end
end
