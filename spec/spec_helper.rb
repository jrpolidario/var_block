require 'bundler/setup'
Bundler.setup

require 'var_block'
# for debugging
require 'byebug'

RSpec.configure do |config|
	config.filter_run :focus => true
	config.run_all_when_everything_filtered = true
end