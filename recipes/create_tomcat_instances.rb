#
# Cookbook Name:: wsi_tomcat
# Recipe:: create_tomcat_instances
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: 
tomcat_home = node[:wsi_tomcat][:user][:home_dir]

node[:wsi_tomcat][:instances].each do |name, attributes|
  port = attributes.port
  ssl  = attributes.key?("ssl") ? attributes.ssl  : { :enabled => false }
  cors = attributes.key?("cors") ? attributes.cors : { :enabled => false }
  auto_start = attributes.key?("auto_start") ? attributes.auto_start : true
  
  wsi_tomcat_instance name do
    port port
    ssl ssl
    tomcat_home tomcat_home
    cors cors
    auto_start auto_start
  end
end
