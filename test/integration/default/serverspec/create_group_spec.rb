require 'spec_helper'

# Make sure that the tomcat group exists
describe group('tomcat') do
  it { should exist }
end