
# Check to make sure gcc is installed
describe package('gcc') do
  it { should be_installed }
end
