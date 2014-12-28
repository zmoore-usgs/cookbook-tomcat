#
# Cookbook Name:: wsi_omcat
# Recipe:: create_group
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Create a tomcat group
group_name = node[:wsi_tomcat][:group][:name]

group group_name do
  action :create
end

