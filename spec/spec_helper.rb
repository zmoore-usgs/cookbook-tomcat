require "chefspec"
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.platform = 'centos'
  config.version = '6.8'
end

at_exit { ChefSpec::Coverage.report! }
