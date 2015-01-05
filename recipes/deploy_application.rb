#
# Cookbook Name:: wsi_tomcat
# Recipe:: deploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Deploys application(s) to a specified tomcat instance

instances = node[:wsi_tomcat][:instances]
tomcat_home = default[:wsi_tomcat][:user][:home_dir]
instances_home = File.expand_path("instance", tomcat_home)

instances.each do |instance, attributes|
  attributes.application.each do |application, app_attributes|
    wsi_tomcat_instance instance do
      application_name application
      action :deploy_app
    end
  end
end


