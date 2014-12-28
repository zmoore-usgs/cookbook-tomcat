require 'spec_helper'

tomcat = 'tomcat'

describe file('/opt/tomcat') do
  it { should be_directory }
  it { be_symlink }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe group(tomcat) do
  it { should exist }
end

describe user(tomcat) do
  it { should exist }
  it { should belong_to_group tomcat }
  it { should have_home_directory '/opt/tomcat' }
  it { should have_login_shell '/bin/bash' }
end
