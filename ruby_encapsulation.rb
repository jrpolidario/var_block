require 'byebug'

module With
	def self.included(base)
		base.extend ClassMethods
	end

	def getvar(block)
		instance_exec &block
	end

	module ClassMethods
		def with(variables, context: nil)
			triggered_variables = TriggeredVariables.new

		 	variables.each do |key, value|
		 		triggered_variables[key] = value
		 	end

		  yield triggered_variables
		end
	end
end

class TriggeredVariables < Hash
	include With::ClassMethods

	def initialize(instance: nil)
		if instance
			raise '`instance` should be a `TriggeredVariables` object' unless instance.is_a? TriggeredVariables
			self.merge(instance)
		end
		self
	end

	def get(context, index)
		context.instance_exec &self[index]
	end

	def with(variables)
		super(variables, context: self)
	end
end

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
	include With
  attr_accessor :title, :disabled

  def initialize(**args)
    args.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end
  end

  foo = 'bar'

  with(fruit: -> { foo }) do |v|
	  v.with(vegetable: -> { 'bean' }, somecondition: -> { disabled }) do |vv|
	    validates :someattribute, presence: true, if: -> { getvar(vv[:somecondition]) }
	  end
  # validates :someattribute, presence: true, if: -> { self.instance_exec &self.class.instance_variable_get(:@somecondition) }
  end
end

# This will be validated from code above
puts '[POST 1]'
post = Post.new(title: 'hahaha', disabled: true)
post.validate

# This will not be validated from code above
puts '[POST 2]'
post = Post.new(title: 'hahaha', disabled: false)
post.validate
