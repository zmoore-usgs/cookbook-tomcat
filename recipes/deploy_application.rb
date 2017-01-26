#
# Cookbook Name:: wsi_tomcat
# Recipe:: deploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Deploys application(s) to a specified tomcat instance

require 'open-uri'

tc_node = node['wsi_tomcat']
instances = tc_node['instances']

instances.each do |instance, attributes|
  next unless attributes.key?('application')
  attributes.application.each do |application, _app_attributes|
    Chef::Log.info("Deploying #{application}")
    wsi_tomcat_instance instance do
      application_name application
      action :deploy_app
    end
  end
end

if tc_node['deploy']['remove_unlisted_applications']
  instances.each do |instance, attributes|
    next unless attributes.key?('application')
    instances[instance]['service_definitions'].each do |sd, _sd_attr|
      # Get the current applications for each instance
      port = sd['connector']['port'].to_s
      databag_name = node['wsi_tomcat']['data_bag_config']['bag_name']
      credentials_attribute = node['wsi_tomcat']['data_bag_config']['credentials_attribute']
      tomcat_script_pass = data_bag_item(databag_name, credentials_attribute)[instance]['tomcat_script_pass']

      begin
        deployed_apps = ManagerClient.get_deployed_applications(port, tomcat_script_pass)
        puts "DEPLOYED APPS: #{deployed_apps}"
        deployed_apps.each do |appname, _attr|
          # Don't delete the manager app if it's supposed to exist
          next unless appname != 'manager' || (appname == 'manager' && node['wsi_tomcat']['disable_manager'])
          next if attributes.application.keys.include?(appname)
          wsi_tomcat_instance instance do
            application_name appname
            action :undeploy_app
          end
        end
      rescue
        # There was an issue communicating with the server. Exit recipe.
        return false
      end
    end
  end
end
