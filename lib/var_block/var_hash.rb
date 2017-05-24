module VarBlock
  class VarHash < Hash
    include VarBlock::Globals

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

        self[key] = VarArray.new([current_value]) unless current_value.is_a? VarArray
        self[key].push(value)
      end
    end
  end
end