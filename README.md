[![Build Status](https://travis-ci.org/jrpolidario/var_block.svg?branch=master)](https://travis-ci.org/jrpolidario/var_block)
[![Gem Version](https://badge.fury.io/rb/var_block.svg)](https://badge.fury.io/rb/var_block)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/jrpolidario/var_block)

## About

* DSL for variable scoping / encapsulation for readability and organisation, by means of block indents and explicit variable declarations
* block is run in the context outside of it (as if you copy-paste the code from inside to outside the block)

## Setup
* Add the following to your `Gemfile`
  ```ruby
  gem 'var_block', '~> 1.1.0'
  ```
* then run `bundle install`
* to use:
  ```ruby
  require 'var_block'
  ```

## Examples

### Basic
```ruby
varblock_with fruit: 'apple' do |v|
  puts varblock_get(v, :fruit)
  # => apple
end
```

### Multiple
```ruby
varblock_with(
  fruit: 'apple',
  vegetable: 'bean'
) do |v|
  puts varblock_get(v, :fruit)
  # => apple
  puts varblock_get(v, :vegetable)
  # => bean
end
```

### Procs
```ruby
current_fruit = 'banana'

varblock_with fruit: -> { current_fruit } do |v|
  puts varblock_get(v, :fruit)
  # => banana
end
```

### Nesting
```ruby
varblock_with fruit: 'orange' do |v|
  puts varblock_get(v, :fruit)
  # => orange

  v.varblock_with vegetable: 'lettuce' do |v|
    puts varblock_get(v, :fruit)
    # => orange
    puts varblock_get(v, :vegetable)
    # => lettuce
  end

  v.varblock_with vegetable: 'onion' do |v|
    puts varblock_get(v, :fruit)
    # => orange
    puts varblock_get(v, :vegetable)
    # => onion
  end
end
```

### Overriding
```ruby
varblock_with fruit: 'orange' do |v|
  v.varblock_with fruit: 'banana' do |v|
    puts varblock_get(v, :fruit)
    # => banana
  end
end
```

### Merging
* will wrap into an Array if not yet an Array
```ruby
varblock_with fruits: 'apple' do |v|
  v.varblock_merge fruits: 'banana'

  puts varblock_get(v, :fruits)
  # => apple
  #    banana
end
```

* will concatenate with the Array if already an Array
```ruby
varblock_with fruits: ['apple', 'banana'] do |v|
  v.varblock_merge fruits: ['grape', 'mango']

  puts varblock_get(v, :fruits)
  # => apple
  #    banana
  #    grape
  #    mango
end
```

* `varblock_merged_with` is just basically `varblock_merge + varblock_with` that accepts a block
```ruby
varblock_with fruits: ['apple', 'banana'] do |v|
  v.varblock_merged_with fruits: ['grape', 'mango'] do |v|
    puts varblock_get(v, :fruits)
    # => apple
    #    banana
    #    grape
    #    mango
  end

  puts varblock_get(v, :fruits)
  # => apple
  #    banana
end
```

### DSL Explanation
```ruby
varblock_with(
  fruit: 'apple',
  vegetable: -> { 'bean' }
) do |v|
  puts v.class
  # => VarBlock::VarHash
  puts v.is_a? Hash
  # => true

  # from above, notice that a VarHash extends a Hash
  # therefore you can also use any Hash method as well like below.

  # NOT RECOMMENDED. use `varblock_get(v, :fruit)` instead when getting the value as it automatically evaluates the value, amongst others things
  puts v[:fruit]
  # => 'apple'
  puts varblock_get(v, :fruit)
  # => 'apple'
  puts v[:vegetable]
  # => #<Proc:0x00...>
  puts varblock_get(v, :vegetable)
  # => 'bean'

  # NOT RECOMMENDED. use `v.varblock_with(fruit: 'banana')` block instead when overwriting the value, as encapsulation is the main purpose of this gem
  v[:fruit] = 'banana'
  v.varblock_with(fruit: 'banana') do
    # ...
  end
end
```

### Options
#### :truthy?
* mimics "AND" logical operator for merged variables
```ruby
varblock_with conditions: 1.is_a?(Integer) do |v|
  v.varblock_merge conditions: !false

  puts varblock_get(v, :conditions, :truthy?)
  # => true
end
```

```ruby
varblock_with conditions: 1.is_a?(String) do |v|
  v.varblock_merge conditions: !false

  puts varblock_get(v, :conditions, :truthy?)
  # => false
end
```

```ruby
condition1 = true
condition2 = true
condition3 = false
condition4 = true

varblock_with conditions: -> { condition1 } do |v|

  v.varblock_merged_with conditions: -> { condition2 } do |v|
    puts varblock_get(v, :conditions, :truthy?)
    # => true
  end

  v.varblock_merged_with conditions: -> { condition3 } do |v|
    puts varblock_get(v, :conditions, :truthy?)
    # => false

    v.varblock_merged_with conditions: -> { condition4 } do |v|
      # returns false because condition3 above is already false. This will not propagate and therefore would not run the proc above for condition4
      puts varblock_get(v, :conditions, :truthy?)
      # => false
    end
  end
end
```

#### :any?
* mimics "OR" logical operator for merged variables
```ruby
varblock_with conditions: 1.is_a?(Integer) do |v|
  v.varblock_merge conditions: false

  puts varblock_get(v, :conditions, :any?)
  # => true
end
```

```ruby
varblock_with conditions: 1.is_a?(String) do |v|
  v.varblock_merge conditions: false

  puts varblock_get(v, :conditions, :any?)
  # => false
end
```

```ruby
condition1 = false
condition2 = false
condition3 = true
condition4 = false

varblock_with conditions: -> { condition1 } do |v|

  v.varblock_merged_with conditions: -> { condition2 } do |v|
    puts varblock_get(v, :conditions, :any?)
    # => false
  end

  v.varblock_merged_with conditions: -> { condition3 } do |v|
    puts varblock_get(v, :conditions, :any?)
    # => true

    v.varblock_merged_with conditions: -> { condition4 } do |v|
      # returns true because condition3 above is already true. This will not propagate and therefore would not run the proc above for condition4
      puts varblock_get(v, :conditions, :any?)
      # => true
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
  varblock_with(ripe_condition: -> { is_ripe }) do |v|
    set_edible if: -> { varblock_get(v, :ripe_condition) } 
  end

  varblock_with(unripe_condition: -> { !is_ripe }) do |v|
    set_inedible if: -> { varblock_get(v, :unripe_condition) }
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

### Advanced
* you can specify a "scope"
```ruby
varblock_with fruit: 'apple' do |v|
  v.varblock_with fruit: 'banana' do |vv|
    vv.varblock_with fruit: 'grape' do |vvv|
      vvv.varblock_with fruit: 'mango' do |vvvv|
        puts varblock_get(v, :fruit)
        # => apple
        puts varblock_get(vv, :fruit)
        # => banana
        puts varblock_get(vvv, :fruit)
        # => grape
        puts varblock_get(vvvv, :fruit)
        # => mango
      end
    end
  end
end
```

* you can also store the variables for later use:
```ruby
my_variables = nil

varblock_with fruits: 'apple' do |v|
  v.varblock_merged_with fruits: 'banana' do |v|
    my_variables = v
  end
end

my_variables.varblock_merged_with fruits: ['grape', 'mango'] do |v|
  puts varblock_get(v, :fruits)
  # => apple
  #    banana
  #    grape
  #    mango
end
```

### Organising Complex Rails Validations (Gem's Initial Intended Purpose)
```ruby
class Post < ApplicationRecord
  # let Post have attributes:
  #   title:string
  #   content:text
  #   category:integer
  #   publish_at:datetime

  CATEGORY_GENERAL = 1
  CATEGORY_PRIORITY = 2

  varblock_with conditions: [] do |v|

    v.varblock_merged_with conditions: -> { category == CATEGORY_GENERAL } do |v|

      validates :publish_at, presence: true, if: -> { varblock_get(v, :conditions, :truthy?) }

      v.varblock_merged_with conditions: -> { content.blank? } do |v|

        validates :title, presence: true, if: -> { varblock_get(v, :conditions, :truthy?) }
        validates :title, length: { maximum: 128 }, if: -> { varblock_get(v, :conditions, :truthy?) }
      end

      v.varblock_merged_with conditions: -> { content.present? } do |v|

        validates :content, length: { maximum: 64 }, if: -> { varblock_get(v, :conditions, :truthy?) }
        validates :title, length: { maximum: 64 }, if: -> { varblock_get(v, :conditions, :truthy?) }
      end
    end

    v.varblock_merged_with conditions: -> { category == CATEGORY_PRIORITY } do |v|

      validates :title, :content, presence: true, if: -> { varblock_get(v, :conditions, :truthy?) }
      validates :title, length: { maximum: 64 }, if: -> { varblock_get(v, :conditions, :truthy?) }
      validates :content, length: { maximum: 512 }, if: -> { varblock_get(v, :conditions, :truthy?) }
      validates :publish_at, presence: true, if: -> { varblock_get(v, :conditions, :truthy?) }

      v.varblock_merged_with conditions: -> { publish_at && publish_at >= Date.today } do |v|

        validate if: -> { varblock_get(v, :conditions, :truthy?) } { errors.add(:publish_at, 'should not be a future date') }
      end
    end
  end
end
```

## Motivation
* I needed to find a way to group model validations in a Rails project because the model has lots of validations and complex `if -> { ... }` conditional logic. Therefore, in hopes to make it readable through indents and explicit declaration of "conditions" at the start of each block, I've written this small gem, and the code then has been a lot more readable and organised though at the expense of getting familiar with it.

## TODOs
* pass in also the `binding` of the current context where `varblock_get` is called into the variable-procs so that the procs are executed with the same `binding` (local variables exactly the same) as the caller context. Found [dynamic_binding](https://github.com/niklasb/ruby-dynamic-binding), but I couldn't think of a way to skip passing in `binding` as an argument to `varblock_get` in hopes to make `varblock_get` as short as possible

## Contributing
* pull requests and forks are very much welcomed! :) Let me know if you find any bug! Thanks

## Thanks
* to `@Jörg W Mittag` for the head start on how to approach to this problem: https://stackoverflow.com/questions/43891007/how-to-define-a-kind-of-block-that-is-used-specifically-for-variable-scoping
* to `@Jack` for his code snippet that I used to fail-safe when same-named methods are includeed which could potentially break dependencies if ignored : https://stackoverflow.com/questions/44156150/how-to-raise-error-when-including-a-module-that-already-has-same-name-methods