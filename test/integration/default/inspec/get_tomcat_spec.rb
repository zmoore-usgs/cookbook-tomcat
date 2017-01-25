

describe file('/opt/tomcat') do
  it { should be_directory }
  it { should be_symlink }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_readable }
end

# Should contain the Tomcat tar.gz file
describe command('ls /opt/*.gz') do
  its('stdout') { should include 'tar.gz' }
end

# Should contain the apache-tomcat directory
describe command('ls /opt/') do
  its('stdout') { should include 'apache-tomcat-' }
end

# The unpackaged directory should be a symlink
describe file('/opt/tomcat') do
	it { should be_symlink }
end
