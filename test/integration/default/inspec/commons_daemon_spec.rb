

describe file('/opt/tomcat/bin/jsvc') do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_mode 0555 }
  it { should be_readable }
  it { should be_executable }
end
