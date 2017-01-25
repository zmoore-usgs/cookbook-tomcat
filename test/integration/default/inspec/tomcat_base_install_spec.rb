

tomcat = 'tomcat'

describe file('/opt/tomcat') do
  it { should be_directory }
  it { be_symlink }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end
