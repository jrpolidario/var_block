lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'var_block/version'

Gem::Specification.new do |s|
  s.name        = 'var_block'
  s.version     = VarBlock::VERSION
  s.date        = '2017-05-24'
  s.summary     = 'Allows variable scoping / encapsulation that will be only accessible inside the given block'
  s.description = 'Allows variable scoping / encapsulation that will be only accessible inside the given block. Useful when trying to group up logic through indents and explicit definitions.'
  s.authors     = ['Jules Roman B. Polidario']
  s.email       = 'jrpolidario@gmail.com'
  s.files       = Dir.glob('lib/**/*')
  s.homepage    = 'http://rubygems.org/gems/var_block'
  s.license     = 'MIT'
  s.required_ruby_version = '~> 2.0'

  s.add_development_dependency 'rspec', '~> 3.2', '>= 3.2.0'
  s.add_development_dependency 'rake'
end