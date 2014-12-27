#
# Cookbook Name:: wsi_tomcat
# Recipe:: creat_euser
# Author: Ivan Suftin isuftin@usgs.gov
#
# Description: Sets up the tomcat user, home directory, etc

group_name = node[:cida_tomcat][:group][:name] || "tomcat"
user_name = node[:cida_tomcat][:user][:name] || "tomcat"
home_dir = node[:cida_tomcat][:user][:home_dir] || "/opt/" + user_name

directory home_dir do
  action :create
end

user user_name do 
  comment "Tomcat user used to access tomcat services"
  system true
  gid group_name
  home home_dir
end