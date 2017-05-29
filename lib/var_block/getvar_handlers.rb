require 'var_block/support'

module VarBlock
  module GetvarHandlers

    OPTIONS = [:truthy?, :any?].freeze

    module DefaultHandler
      def self.handle(value, options = [])
        supported_options = []
        unsupported_options = options - supported_options
        raise ArgumentError, "#{unsupported_options.map(&:inspect).join(', ')} option(s) are not supported on non-merged variables" if unsupported_options.any?
        value
      end
    end

    module ProcHandler
      def self.handle(value, context, options = [])
        supported_options = []
        unsupported_options = options - supported_options
        raise ArgumentError, "#{unsupported_options.map(&:inspect).join(', ')} option(s) are not supported on non-merged variables" if unsupported_options.any?
        context.instance_exec(&value)
      end
    end

    module VarArrayHandler
      class << self
        include VarBlock::Support

        def handle(value, context, options)
          if options.any? 
            return handle_options(value, options)

          # else, if no options, defaults to return as a wrapped Array
          else
            merged_values = []

            value.each do |v|
              if v.is_a? Proc
                merged_values = merged_values + array_wrap(ProcHandler.handle(v, context))
              else
                merged_values = merged_values + array_wrap(DefaultHandler.handle(v))
              end
            end

            return merged_values
          end
        end

        private

        def handle_options(value, options)
          options.each do |option|
            case option

            when :truthy?
              return handle_option_truthy(value)

            when :any?
              return handle_option_any(value)
            end
          end
        end

        def handle_option_truthy(values)
          is_truthy = true

          values.each do |value|
            if value.is_a? Proc
              evaluated_value = ProcHandler.handle(value, context)
            else
              evaluated_value = DefaultHandler.handle(value)
            end
            is_truthy = !!evaluated_value
            break unless is_truthy
          end

          return is_truthy
        end

        def handle_option_any(values)
          values.each do |value|
            if value.is_a? Proc
              evaluated_value = ProcHandler.handle(value, context)
            else
              evaluated_value = DefaultHandler.handle(value)
            end
            is_truthy = !!evaluated_value
            return true if is_truthy
          end

          return false
        end
      end
    end
  end
end