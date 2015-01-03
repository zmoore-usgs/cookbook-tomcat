#
# Cookbook Name:: wsi_tomcat
# Recipe:: deploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: 
name = 'default'
wsi_tomcat_instance name do
  application_name 'psiprobe'
  name name
  action :deploy_app
end