#
# Cookbook Name:: wsi_tomcat
# Recipe:: creat_euser
# Author: Ivan Suftin isuftin@usgs.gov
#
# Description: Sets up the tomcat user, home directory, etc

group_name = node[:wsi_tomcat][:group][:name]
user_name = node[:wsi_tomcat][:user][:name]
home_dir = node[:wsi_tomcat][:user][:home_dir]

directory home_dir do
  action :create
end

user user_name do 
  comment "Tomcat user used to access tomcat services"
  system true
  gid group_name
  home home_dir
end