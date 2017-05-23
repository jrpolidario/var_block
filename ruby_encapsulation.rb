require 'byebug'

class With
  def initialize(**variables)
    @variables = variables
  end
end

def with(**variables)
  ref = With.new(variables)

  variables.each do |key, value|
  	define_method key do
  		instance_exec &value
  	end
    # instance_variable_set("@#{key}".to_sym, value)
    yield
    # remove_instance_variable("@#{key}".to_sym)
  end
end

module Validators
	def validate
   	self.class.instance_variable_get(:@_validations).each do |validation|
   		unless (if_condition = validation[:options][:if]).nil?
   			if self.instance_exec(&if_condition)
   				puts '"if condition" is `true`, this will then trigger validation'
   			end
   		end
   	end
  end
end

class Record
	include Validators

	def self.validates(*attributes, **options)
		@_validations ||= []
		@_validations << {attributes: attributes, options: options}
	end
end

class Post < Record
	attr_accessor :title, :disabled

	def initialize(**args)
		args.each do |key, value|
			self.instance_variable_set("@#{key}".to_sym, value)
		end
	end

  foo = 'bar'

  with(fruit: -> { foo }) do
  	with(vegetable: -> { 'bean' }, somecondition: -> { disabled }) do
  		validates :someattribute, presence: true, if: -> { somecondition }
  		# validates :someattribute, presence: true, if: -> { self.instance_exec &self.class.instance_variable_get(:@somecondition) }
	  end
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