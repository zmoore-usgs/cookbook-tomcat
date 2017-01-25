
tomcat = 'tomcat'
describe user(tomcat) do
  it { should exist }
  its('groups') { should include('tomcat') }
  its('home') { should eq '/opt/' + tomcat }
  its('shell') { should eq '/bin/bash' }
end
