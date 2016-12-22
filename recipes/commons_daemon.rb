#
# Cookbook Name:: wsi_tomcat
# Recipe:: commons_daemon
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Build Commons Daemon Package for jsvc executable

user_name = node['wsi_tomcat']['user']['name']
group_name = node['wsi_tomcat']['group']['name']
tomcat_home = node['wsi_tomcat']['user']['home_dir']
unpack_directory = "#{Chef::Config[:file_cache_path]}/opt/commons_daemon"
work_directory = "#{unpack_directory}/unix"
java_home = -> { node['java']['java_home'] } # This needs lazy evaluation
# TODO: Does java_home still need lazy evaluation now that the JAVA cookbook
# has been moved out as a dependency of this cookbook?
# node["java"]["java_home"] may not even exist if the cookbook author
# decides not to use the JAVA cookbook

directory 'Create BCDP build dir' do
  path unpack_directory
  owner user_name
  group group_name
  recursive true
  only_if { ! ::File.exist?("#{tomcat_home}/bin/jsvc") }
end

execute 'Unpack BCDP source' do
  user user_name
  group group_name
  command "/bin/tar xvf #{tomcat_home}/bin/commons-daemon-native.tar.gz --strip=1 -C #{unpack_directory}"
  not_if "test -n \"$(ls -A #{unpack_directory})\""
  only_if { ! ::File.exist?("#{tomcat_home}/bin/jsvc") }
end

execute 'Run configure on BCDP source' do
  command "./configure --with-java=#{java_home.call}"
  user user_name
  group group_name
  cwd work_directory
  environment 'JAVA_HOME' => java_home.call
  not_if { File.exist?("#{work_directory}/config.status") || File.exist?("#{tomcat_home}/bin/jsvc") }
end

execute 'Run make on BCDP source' do
  command 'make'
  user user_name
  group group_name
  cwd work_directory
  not_if { File.exist?("#{work_directory}/jsvc") || File.exist?("#{tomcat_home}/bin/jsvc") }
end

execute 'Copy executable to tomcat bin' do
  command "/bin/cp #{work_directory}/jsvc  #{tomcat_home}/bin"
  only_if { ! ::File.exist?("#{tomcat_home}/bin/jsvc") }
end

file 'set permissions on BCDP binary' do
  path "#{tomcat_home}/bin/jsvc"
  mode 0555
  user user_name
  group group_name
  only_if { ::File.exist?("#{tomcat_home}/bin/jsvc") }
end

directory 'Delete BCDP build dir' do
  path unpack_directory
  recursive true
  action :delete
  only_if { ::File.exist?("#{tomcat_home}/bin/jsvc") }
end
