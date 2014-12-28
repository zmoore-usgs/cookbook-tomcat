require 'spec_helper'

# Verify that BCDP binary is installed
describe file('/opt/tomcat/bin/jsvc') do
  it { should be_file }
  it { should be_mode 555 }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end