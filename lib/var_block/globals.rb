require 'var_block/getvar_handlers'

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
      unsupported_options = (options - VarBlock::GetvarHandlers::SUPPORTED_OPTIONS)
      raise ArgumentError, "3rd argument options Array only supports #{VarBlock::GetvarHandlers::SUPPORTED_OPTIONS}. Does not support #{unsupported_options.map(&:inspect).join(', ')}" if unsupported_options.any?
      raise ArgumentError, "1st argument should be a VarHash object, but is found to be a #{var_hash.class}" unless var_hash.is_a? VarHash
      raise ArgumentError, "2nd argument :#{index} is not defined. Defined are #{var_hash.keys.map(&:inspect).join(', ')}" unless var_hash.keys.include?(index)

      value = var_hash[index]

      return_value = case value
                     when VarArray
                       VarBlock::GetvarHandlers.handle_var_array(value, self, options)
                     when Proc
                       VarBlock::GetvarHandlers.handle_proc(value, self)
                     else
                       VarBlock::GetvarHandlers.handle_default(value)
                     end

      return_value
    end

    def with(var_hash_parent = nil, **variables)
      var_hash = VarHash.new(var_hash: var_hash_parent)

      variables.each do |key, value|
        var_hash[key] = value
      end

      yield var_hash
    end
  end
end
