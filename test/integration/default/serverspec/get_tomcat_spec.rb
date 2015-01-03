require 'spec_helper'

describe file('/opt/tomcat') do
  it { should be_directory }
  it { should be_symlink }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_readable }
end