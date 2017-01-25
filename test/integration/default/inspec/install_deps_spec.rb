

# Check to make sure Java is installed
describe command('echo $JAVA_HOME') do
  its(:stdout) { should start_with('/usr/lib/jvm/java')}
end

# Where is it installed?
describe command('which java') do
  its('stdout') { should include '/usr/bin/java' }
end

# Check to make sure gcc is installed
describe package('gcc') do
  it { should be_installed }
end
