require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'goliath/test_helper'
require 'trackomatic'

RSpec.configure do |c|
  # c.include Goliath::TestHelper, :example_group => {
    # :file_path => /spec\/integration/
  # }
end
