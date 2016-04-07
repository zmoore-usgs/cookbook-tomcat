require 'spec_helper'

describe file('/opt/tomcat/instance/default') do
  it { should be_directory }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_readable }
end

%w{bin conf lib logs temp webapps work}.each do |dir|
  describe file("/opt/tomcat/instance/default/#{dir}") do
    it { should be_directory }
    it { should be_owned_by 'tomcat' }
    it { should be_grouped_into 'tomcat' }
    it { should be_readable }
  end
end

[ "catalina.policy",
  "catalina.properties",
  "logging.properties",
  "context.xml",
  "logging.properties",
  "server.xml",
  "tomcat-users.xml",
  "web.xml"
].each do |cfg|
  describe file("/opt/tomcat/instance/default/conf/#{cfg}") do
    it { should be_file }
    it { should be_owned_by 'tomcat' }
    it { should be_grouped_into 'tomcat' }
    it { should be_readable }
  end
end

%w{start stop}.each do |bin_file|
  describe file("/opt/tomcat/bin/#{bin_file}_default") do
    it { should be_file }
    it { should be_owned_by 'tomcat' }
    it { should be_grouped_into 'tomcat' }
    it { should be_readable }
    it { should be_executable }
  end
end

describe file("/opt/tomcat/instance/default/bin/setenv.sh") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_readable }
  it { should be_executable }
end

describe file("/opt/tomcat/instance/default/bin/catalinaopts.sh") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_readable }
  it { should be_executable }
end

describe file("/etc/init.d/tomcat-default") do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_readable }
  it { should be_executable }
end

describe file("/opt/tomcat/instance/default/webapps/manager") do
  it { should be_directory }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_readable }
end

describe file("/opt/tomcat/instance/default/bin/tomcat-juli.jar") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
  it { should be_readable }
end

describe command('/sbin/chkconfig') do
  its(:stdout) { should match /(tomcat-default\s.*0:off\s.*1:off\s.*2:on\s.*3:on\s.*4:on\s.*5:off\s.*6:off)/ }
  end  
  
  describe command('service tomcat status default') do
    its(:stdout) { should match /is running/ }
end
