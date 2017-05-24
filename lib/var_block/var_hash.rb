module VarBlock
  class VarHash < Hash
    include Globals

    def initialize(var_hash: nil)
      if var_hash
        raise ArgumentError.new('`instance` should be a `VarHash` object') unless var_hash.is_a? VarHash
        self.merge!(var_hash)
      end
      self
    end

    def with(variables)
      super(variables, var_hash: self)
    end
  end
end