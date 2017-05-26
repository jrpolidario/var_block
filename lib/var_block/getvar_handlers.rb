require 'var_block/support'

module VarBlock
  module GetvarHandlers

    SUPPORTED_OPTIONS = [:truthy?].freeze

    class << self
      include VarBlock::Support

      def handle_var_array(value, context, options)
        # if :truthy?, we need to check each item in the array, and return false immediately if at least one is found to be not "truthy", else return true
        if options.any? && options.include?(:truthy?)
          is_truthy = true

          value.each do |v|
            if v.is_a? Proc
              is_truthy = handle_proc(v, context)
            else
              is_truthy = handle_default(v)
            end
            break unless is_truthy
          end

          return is_truthy

        # else, if no options, defaults to return as a wrapped Array
        else
          merged_values = []

          value.each do |v|
            if v.is_a? Proc
              merged_values = merged_values + array_wrap(handle_proc(v, context))
            else
              merged_values = merged_values + array_wrap(handle_default(v))
            end
          end

          return merged_values
        end
      end

      def handle_proc(value, context)
        context.instance_exec(&value)
      end

      def handle_default(value)
        value
      end
    end
  end
end