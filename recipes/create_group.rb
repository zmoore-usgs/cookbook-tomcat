#
# Cookbook Name:: wsi_omcat
# Recipe:: create_group
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Create a tomcat group
group_name = node[:cida_tomcat][:group][:name] || "tomcat"

group group_name do
  action :create
end

