require 'spec_helper'

tomcat = 'tomcat'

# Verify that java is installed
describe command('java -version') do
  its(:exit_status) { should eq 0 }
end

# Verify that gcc is installed
describe command('gcc --version') do
  its(:exit_status) { should eq 0 }
end
