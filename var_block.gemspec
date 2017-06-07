lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'var_block/version'

Gem::Specification.new do |s|
  s.name        = 'var_block'
  s.version     = VarBlock::VERSION
  s.date        = '2017-06-07'
  s.summary     = 'DSL for variable scoping / encapsulation for readability and organisation, by means of block indents and explicit variable declarations'
  s.description = 'DSL for variable scoping / encapsulation for readability and organisation, by means of block indents and explicit variable declarations. Useful when organising complex conditions such as procs (case-in-point: complex `... if: -> {}` Rails model validations'
  s.authors     = ['Jules Roman B. Polidario']
  s.email       = 'jrpolidario@gmail.com'
  s.files       = Dir.glob('lib/**/*')
  s.homepage    = 'http://rubygems.org/gems/var_block'
  s.license     = 'MIT'
  s.required_ruby_version = '~> 2.0'

  s.add_development_dependency 'rspec', '~> 3.2', '>= 3.2.0'
  s.add_development_dependency 'rake', '~> 12.0' # TODO: check compatibility with older versions
  s.add_development_dependency 'byebug', '~> 9.0'  # TODO: check compatibility with older versions
end