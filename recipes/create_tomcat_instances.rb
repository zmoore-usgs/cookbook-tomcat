#
# Cookbook Name:: wsi_tomcat
# Recipe:: create_tomcat_instances
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: 
tomcat_home = node[:wsi_tomcat][:user][:home_dir]

node[:wsi_tomcat][:instances].each do |name, attributes|
  port = attributes.port
  ssl  = node.attribute?("ssl") ? attributes.ssl : { :enabled => false }
  wsi_tomcat_instance name do
    port port
    ssl ssl
    tomcat_home tomcat_home
  end
end
