#
# Cookbook Name:: wsi_tomcat
# Recipe:: deploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Deploys application(s) to a specified tomcat instance

tc_node = node['wsi_tomcat']

tc_node['instances'].each do |instance, attributes|
  # If this instance does not have any applications defined, move on
  next unless attributes.key?('application')

  attributes['application'].each do |application, application_attributes|
    # TODO : We can probably use the Chef::Helper::ManagerClient to perform this
    tomcat_application application do
      instance_name instance
      version application_attributes.member?('version') ? application_attributes['version'] : ''
      location application_attributes['location']
      path application_attributes['path']
      type application_attributes['type']
      action :deploy
    end
  end
end
