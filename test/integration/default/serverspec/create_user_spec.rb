require 'spec_helper'
tomcat = 'tomcat'
describe user(tomcat) do
  it { should exist }
  it { should belong_to_group tomcat }
  it { should have_home_directory '/opt/' + tomcat }
  it { should have_login_shell '/bin/bash' }
end