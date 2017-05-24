* THIS GEM IS STILL WIP (WORK IN PROGRESS)

# About

* allows variable scoping / encapsulation which will be only accessible inside the given block.
* block is run in the context outside of it (as if you copy-paste the code from inside to outside the block)

# Installation
* Add the following to your `Gemfile`
  ```
  gem 'var_block'
  ```
* then run `bundle install`

# Examples

## Simple
```
with(fruit: 'apple') do |v|
  puts getvar(v, :fruit)
  # => apple
end
```

## Procs
```
current_fruit = 'banana'

with(fruit: -> { current_fruit }) do |v|
  puts getvar(v, :fruit)
  # => banana
end
```

## Nesting
```
with(fruit: 'orange') do |v|
  puts getvar(v, :fruit)
  # => orange

  v.with(vegetable: 'lettuce') do |v|
    puts getvar(v, :fruit)
    # => orange
    puts getvar(v, :vegetable)
    # => lettuce
  end

  v.with(vegetable: 'onion') do |v|
    puts getvar(v, :fruit)
    # => orange
    puts getvar(v, :vegetable)
    # => onion
  end
end
```

## Merging
```
with(fruits: ['apple', 'banana']) do |v|
  v.merge(fruits: ['grape', 'mango'])

  puts getvar(v, :fruits)
  # => apple
  #    banana
  #    grape
  #    mango
end
```

## Options
### :truthy?
```
with(conditions: -> { [1 == 1, 1.is_a?(Fixnum)] }) do |v|
  v.merge(conditions: -> { [true, true == true, !false] } )

  puts getvar(v, :conditions, :truthy?)
  # puts true
end

with(conditions: -> { [1 == 1, 1.is_a?(Fixnum)] }) do |v|
  v.merge(conditions: -> { [false, true == true, true] } )

  puts getvar(v, :conditions, :truthy?)
  # puts false
end
```

## Classes & Instances
```
class Fruit
  attr_accessor :name, :is_ripe

  def initialize(**args)
    args.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end
    self
  end

  def self.set_edible(**args)
    @set_edible_proc = args[:if]
  end

  def self.set_inedible(**args)
    @set_inedible_proc = args[:if]
  end

  with(ripe_condition: -> { is_ripe }) do |v|
    set_edible if: -> { getvar(v, :ripe_condition) } 
  end

  with(unripe_condition: -> { !is_ripe }) do |v|
    set_inedible if: -> { getvar(v, :unripe_condition) }
  end

  def is_edible?
    instance_exec &self.class.instance_variable_get(:@set_edible_proc)
  end

  def is_inedible?
    instance_exec &self.class.instance_variable_get(:@set_inedible_proc)
  end
end

fruit = Fruit.new(name: 'apple', is_ripe: true)
fruit.is_edible?
# => true
fruit.is_inedible?
# => false

fruit = Fruit.new(name: 'banana', is_ripe: false)
fruit.is_edible?
# => false
fruit.is_inedible?
# => true
```

## Motivation
* I needed to find a way to group model validations in a Rails project because the model has lots of validations and complex "if -> { ... }" conditional logic. Therefore, in hopes to make it readable through indents and explicitly declaration of "conditions" at the start of each block, the code has been a lot more readable and organised though at the expense getting familiar with it.