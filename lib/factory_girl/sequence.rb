module FactoryGirl

  # Sequences are defined using sequence within a FactoryGirl.define block.
  # Sequence values are generated using next.
  # @api private
  class Sequence
    attr_reader :name

    def initialize(name, *args, &proc)
      @name    = name
      @proc    = proc

      options  = args.extract_options!
      @value   = args.first || 1
      @aliases = options.fetch(:aliases) { [] }

      if !@value.respond_to?(:peek)
        @value = EnumeratorAdapter.new(@value)
      end
    end

    def next(scope = nil)
      if @proc
        if scope
          scope.instance_exec(@value.peek, &@proc)
        else
          @proc.call(@value.peek)
        end
      else
        @value.peek
      end
    ensure
      @value.next
    end

    def names
      [@name] + @aliases
    end

    private

    class EnumeratorAdapter
      def initialize(value)
        @value = value
      end

      def peek
        @value
      end

      def next
        @value = @value.next
      end
    end
  end
end
