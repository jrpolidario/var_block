module VarBlock
  module GetvarHandlers
    class << self
      def handle_var_array(value, context)
        merged_values = []

        value.each do |v|
          if v.is_a? Proc
            merged_values = merged_values + handle_proc(v, context)
          else
            merged_values = merged_values + handle_default(v, context)
          end
        end

        merged_values
      end

      def handle_proc(value, context)
        context.instance_exec &value
      end

      def handle_default(value, context)
        value
      end

      def handle_options(value, context, options)
        return_value = value

        options.each do |option|
          case option
          when :truthy?
            ArgumentError.new("value should be an Array, but is found to be a #{value.class}") unless value.is_a? Array
            return_value = !return_value.any?{|v| !!!v }
          else
            raise ArgumentError.new("#{option} not supported!")
          end
        end

        return_value
      end
    end
  end
end