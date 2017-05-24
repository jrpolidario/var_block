require 'byebug'

###############
##### LIB #####
###############

module VarBlock
  module Globals
    def self.included(base)
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

  class VarHash < Hash
    include Globals

    def initialize(var_hash: nil)
      if var_hash
        raise ArgumentError.new('`instance` should be a `TriggeredVariables` object') unless var_hash.is_a? VarHash
        self.merge!(var_hash)
      end
      self
    end

    def with(variables)
      super(variables, var_hash: self)
    end
  end
end

class Object
  include VarBlock::Globals
end

################
##### MISC #####
################

module Validators
  def validate
    self.class.instance_variable_get(:@_validations).each do |validation|
      unless (if_condition = validation[:options][:if]).nil?
        next unless instance_exec(&if_condition)
        puts '"if condition" is `true`, this will then trigger validation'
      end
    end
  end
end

class Record
  include Validators

  def self.validates(*attributes, **options)
    @_validations ||= []
    @_validations << { attributes: attributes, options: options }
  end
end

class Post < Record
  include VarBlock
  attr_accessor :title, :disabled

  def initialize(**args)
    args.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end
  end

  foo = 'bar'

  # USAGE
  
  with(fruit: -> { foo }) do |v|
    v.with(vegetable: -> { 'bean' }, somecondition: -> { disabled }) do |vv|
      validates :someattribute, presence: true, if: -> { getvar(vv, :somecondition) }
    end
    validates :someattribute, presence: true, if: -> { !getvar(v, :fruit).nil? }
  end
end

#################
#### EXAMPLE ####
#################

# This will be validated from code above
puts '[POST 1]'
post = Post.new(title: 'hahaha', disabled: true)
post.validate

# This will not be validated from code above
puts '[POST 2]'
post = Post.new(title: 'hahaha', disabled: false)
post.validate
