module VarBlock
  module Globals
    def self.included(base)
      # fail if there is already same-name methods to prevent breaking dependencies
      overrides = instance_methods.select { |method| base.instance_method(method).owner != self }
      raise "#{self.name} overrides #{overrides.join(', ')}" if overrides.any?

      base.extend self
    end

    def getvar(triggered_variables, index)
      instance_exec &triggered_variables[index]
    end

    def with(variables, var_hash: nil)
      var_hash = VarHash.new(var_hash: var_hash)

      variables.each do |key, value|
        var_hash[key] = value
      end

      yield var_hash
    end
  end
end