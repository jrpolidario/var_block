require 'var_block/globals'
require 'var_block/support'

module VarBlock
  class VarHash < Hash
    include VarBlock::Globals
    include VarBlock::Support

    def self.new_from_var_hash(var_hash: nil)
      new_var_hash = VarHash.new
      if var_hash
        raise ArgumentError.new('`instance` should be a `VarHash` object') unless var_hash.is_a? VarHash
        new_var_hash = new_var_hash.merge!(var_hash.to_h)
      end
      new_var_hash
    end

    def varblock_with(variables = {})
      super(self, variables)
    end

    def varblock_merge(variables)
      raise ArgumentError, '`varblock_merge` does not accept a block. Are you looking for `varblock_merged_with` instead?' if block_given?
      
      variables.each do |key, value|
        current_value = self[key]

        # if variable already has a value, we need to wrap both values into a VarArray if not yet a VarArray
        if self.has_key?(key)
          unless current_value.is_a? VarArray
            self[key] = VarArray.new(array_wrap(current_value) + array_wrap(value))
          else
            self[key] = self[key].clone.concat(array_wrap(value))
          end
          
        # else if new variable
        else
          self[key] = value
        end
      end
    end

    def varblock_merged_with(variables = {})
      cloned_self = self.clone
      cloned_self.varblock_merge(variables)
      cloned_self.varblock_with() { yield(cloned_self) }
    end
  end
end