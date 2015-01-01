#
# Cookbook Name:: wsi_tomcat
# Recipe:: create_tomcat_instances
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: 

node[:wsi_tomcat][:instances].each do |name, attributes|
  port = attributes.port
  ssl  = attributes.ssl
  wsi_tomcat_instance name do
    port port
    ssl ssl
  end
end
