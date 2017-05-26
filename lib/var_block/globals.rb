module VarBlock
  module Globals
    def self.included(base)
      # fail if there is already same-name methods to prevent breaking dependencies
      # thanks to Jack, https://stackoverflow.com/questions/44156150/how-to-raise-error-when-including-a-module-that-already-has-same-name-methods
      overrides = instance_methods.reject { |method| base.instance_method(method).owner == self }
      raise "#{name} overrides #{overrides.join(', ')}" if overrides.any?

      base.extend self
    end

    def getvar(var_hash, index, *options)
      raise ArgumentError, '1st argument should be a VarHash object!' unless var_hash.is_a? VarHash

      value = var_hash[index]

      return_value = case value
                     when VarArray
                       VarBlock::GetvarHandlers.handle_var_array(value, self)
                     when Proc
                       VarBlock::GetvarHandlers.handle_proc(value, self)
                     else
                       VarBlock::GetvarHandlers.handle_default(value)
                     end

      unless options.empty?
        return_value = VarBlock::GetvarHandlers.handle_options(return_value, options)
      end

      return_value
    end

    def with(var_hash = nil, **variables)
      var_hash = VarHash.new(var_hash: var_hash)

      variables.each do |key, value|
        var_hash[key] = value
      end

      yield var_hash
    end
  end
end
