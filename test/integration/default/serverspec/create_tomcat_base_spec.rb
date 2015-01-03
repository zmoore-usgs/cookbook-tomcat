require 'spec_helper'

create_home_dirs = [
  "instance",
  "heapdumps",
  "data",
  "run",
  "share",
  "ssl",
  "ssltmp",
  "archives"
]

create_home_dirs.each do |dir| 
  describe file("/opt/tomcat/#{dir}") do
    it { should be_directory }
    it { should be_owned_by 'tomcat' }
    it { should be_grouped_into 'tomcat' }
  end
end

describe file("/opt/tomcat/archives/manager_war.tar.gz") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe file("/opt/tomcat/archives/tomcat-juli.jar") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe file("/opt/tomcat/.bash_profile") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe file("/opt/tomcat/.bashrc") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe file("/opt/tomcat/archives/tomcat-juli.jar") do
  it { should be_file }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe file("/opt/tomcat/bin/tomcat") do
  it { should be_file }
  it { should be_executable }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe file("/etc/init.d/tomcat") do
  it { should be_file } 
  it { should be_executable }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

