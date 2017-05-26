[![Build Status](https://travis-ci.org/jrpolidario/var_block.svg?branch=master)](https://travis-ci.org/jrpolidario/var_block)
[![Gem Version](https://badge.fury.io/rb/var_block.svg)](https://badge.fury.io/rb/var_block)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/jrpolidario/var_block)

* THIS GEM IS STILL WIP (WORK IN PROGRESS), BUT EXAMPLES BELOW ARE ALREADY IMPLEMENTED

## About

* allows variable scoping / encapsulation which will be only accessible inside the given block.
* block is run in the context outside of it (as if you copy-paste the code from inside to outside the block)

## Setup
* Add the following to your `Gemfile`
  ```ruby
  gem 'var_block'
  ```
* then run `bundle install`
* to use:
  ```ruby
  require 'var_block'
  ```

## Examples

### Simple
```ruby
with fruit: 'apple' do |v|
  puts getvar(v, :fruit)
  # => apple
end
```

### Multiple
```ruby
with(
  fruit: 'apple',
  vegetable: 'bean'
) do |v|
  puts getvar(v, :fruit)
  # => apple
  puts getvar(v, :vegetable)
  # => bean
end
```

### Procs
```ruby
current_fruit = 'banana'

with fruit: -> { current_fruit } do |v|
  puts getvar(v, :fruit)
  # => banana
end
```

### Nesting
```ruby
with fruit: 'orange' do |v|
  puts getvar(v, :fruit)
  # => orange

  v.with vegetable: 'lettuce' do |v|
    puts getvar(v, :fruit)
    # => orange
    puts getvar(v, :vegetable)
    # => lettuce
  end

  v.with vegetable: 'onion' do |v|
    puts getvar(v, :fruit)
    # => orange
    puts getvar(v, :vegetable)
    # => onion
  end
end
```

### Overriding
```
with fruit: 'orange' do |v|
  v.with fruit: 'banana' do |v|
    puts getvar(v, :fruit)
    # => banana
  end
end
```

### Merging
```ruby
with fruits: 'apple' do |v|
  v.merge fruits: 'banana'

  puts getvar(v, :fruits)
  # => apple
  #    banana
end

with fruits: ['apple', 'banana'] do |v|
  v.merge fruits: ['grape', 'mango']

  puts getvar(v, :fruits)
  # => apple
  #    banana
  #    grape
  #    mango
end

with fruits: ['apple', 'banana'] do |v|
  v.merged_with fruits: ['grape', 'mango'] do |v|
    puts getvar(v, :fruits)
    # => apple
    #    banana
    #    grape
    #    mango
  end

  puts getvar(v, :fruits)
  # => apple
  #    banana
end
```

### Options
#### :truthy?
```ruby
with conditions: (1 == 1 && 1.is_a?(Fixnum)) do |v|
  v.merge conditions: !false

  puts getvar(v, :conditions, :truthy?)
  # true
end

with conditions: (1 == 1 && 1.is_a?(String)) do |v|
  v.merge conditions: !false

  puts getvar(v, :conditions, :truthy?)
  # false
end


condition1 = true
condition2 = true
condition3 = false
condition4 = true

with conditions: -> { condition1 } do |v|

  v.merged_with conditions: -> { condition2 } do |v|
    puts getvar(v, :conditions, :truthy?)
    # => true
  end

  v.merged_with conditions: -> { condition3 } do |v|
    puts getvar(v, :conditions, :truthy?)
    # => false

    v.merged_with conditions: -> { condition4 } do |v|
      # returns false because condition3 above is already false. This will not propagate and therefore would not run the proc above for condition4
      puts getvar(v, :conditions, :truthy?)
      # => false
    end
  end
end
```

### Classes & Instances
```ruby
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


  # usage example
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
* I needed to find a way to group model validations in a Rails project because the model has lots of validations and complex `if -> { ... }` conditional logic. Therefore, in hopes to make it readable through indents and explicit declaration of "conditions" at the start of each block, I've written this small gem, and the code then has been a lot more readable and organised though at the expense of getting familiar with it.

## TODOs
* pass in also the `binding` of the current context where `getvar` is called into the variable-procs so that the procs are executed with the same `binding` (local variables exactly the same) as the caller context. Found [dynamic_binding](https://github.com/niklasb/ruby-dynamic-binding), but I couldn't think of a way to skip passing in `binding` as an argument to `getvar` in hopes to make `getvar` as short as possible

## Thanks
* to `@Jörg W Mittag` for the head start on how to approach to this problem: https://stackoverflow.com/questions/43891007/how-to-define-a-kind-of-block-that-is-used-specifically-for-variable-scoping
* to `@Jack` for his code snippet that I used to fail-safe when same-named methods are includeed which could potentially break dependencies if ignored : https://stackoverflow.com/questions/44156150/how-to-raise-error-when-including-a-module-that-already-has-same-name-methods