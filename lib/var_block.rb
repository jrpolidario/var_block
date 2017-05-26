Dir[__dir__ + '/var_block/*.rb'].each {|file| require file }

module VarBlock
end

class Object
  include VarBlock::Globals
end
