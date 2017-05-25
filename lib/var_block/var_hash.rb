require 'var_block/globals'
require 'var_block/support'

module VarBlock
  class VarHash < Hash
    include VarBlock::Globals
    include VarBlock::Support

    def initialize(var_hash: nil)
      if var_hash
        raise ArgumentError.new('`instance` should be a `VarHash` object') unless var_hash.is_a? VarHash
        self.merge!(var_hash)
      end
      self
    end

    def with(variables = {})
      super(self, variables)
    end

    def merge(variables)
      variables.each do |key, value|
        current_value = self[key]

        # if variable already has a value, we need to wrap both values into a VarArray if not yet a VarArray
        if self.has_key?(key)
          self[key] = VarArray.new(array_wrap(current_value) + array_wrap(value)) unless current_value.is_a? VarArray
          
        # else if new variable
        else
          self[key] = value
        end
      end
    end

    def merged_with(variables = {})
      cloned_self = self.clone
      cloned_self.merge(variables)
      cloned_self.with() { yield(cloned_self) }
    end
  end
end