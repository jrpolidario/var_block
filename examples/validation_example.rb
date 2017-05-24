require 'byebug'
# use installed gem
# require 'var_block'
# or use directly the code from lib
require File.join(__dir__, '..', 'lib', 'var_block.rb')

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

  # var_block USAGE

  with(fruit: -> { foo }) do |v|
    v.with(vegetable: 'bean', somecondition: -> { disabled }) do |vv|
      validates :someattribute, presence: true, if: -> { getvar(vv, :somecondition) }
    end

    validates :someattribute, presence: true, if: -> { !getvar(v, :fruit).nil? }
  end

  with(conditions: -> { [disabled, title == 'hahaha'] }) do |v|
    v.merge(conditions: -> { [true, true] })

    v.with do |v|
      validates :someattribute, presence: true, if: -> { getvar(v, :conditions, :truthy?) }
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
