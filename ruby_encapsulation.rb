require 'byebug'

class With
  def initialize(**variables)
    @variables = variables
  end
end

class TriggeredVariables < Hash
	def initialize(context:)
		@context = context
	end

	def [](index)
		byebug
		@context.instance_exec &super(index)
	end
end

def with(variables)
  # ref = With.new(variables)

  # variables.each do |key, value|
  # 	define_method key do
  # 		instance_exec &value
  # 	end
  #   # instance_variable_set("@#{key}".to_sym, value)
  #   yield
  #   # remove_instance_variable("@#{key}".to_sym)
  # end
  # variables = {}
  # variables_proc_binding = variables_proc.().binding
  # defined_variables = variables_proc.().binding.local_variables
 	# defined_variables.each do |defined_variable|
 	# 	variables[defined_variable] = variables_proc_binding.local_variable_get(defined_variable)
 	# end

 	# asdf = 'asdfasdf'
 	triggered_variables = TriggeredVariables.new(context: self)

 	variables.each do |key, value|
 		triggered_variables[key] = value
 	end

  yield triggered_variables #variables
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
  attr_accessor :title, :disabled

  def initialize(**args)
    args.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end
  end

  foo = 'bar'

  # with(
  # 	fruit = -> { foo }
  # ) do

  with(vegetable: -> { 'bean' }, somecondition: -> { disabled }) do |variables|
    validates :someattribute, presence: true, if: -> { variables[:somecondition] }
  end
  # validates :someattribute, presence: true, if: -> { self.instance_exec &self.class.instance_variable_get(:@somecondition) }
  # end
end

# This will be validated from code above
puts '[POST 1]'
post = Post.new(title: 'hahaha', disabled: true)
post.validate

# This will not be validated from code above
puts '[POST 2]'
post = Post.new(title: 'hahaha', disabled: false)
post.validate
