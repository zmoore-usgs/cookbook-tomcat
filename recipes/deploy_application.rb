#
# Cookbook Name:: wsi_tomcat
# Recipe:: deploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Deploys application(s) to a specified tomcat instance
require 'open-uri'

instances = node['wsi_tomcat']['instances']

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

if node['wsi_tomcat']['deploy']['remove_unlisted_applications']
  instances.each do |instance, attributes|
    next unless attributes.key?('application')
    node['wsi_tomcat']['instances'][instance]['service_definitions'].each do |sd, _sd_attr|
      # Get the current applications for each instance
      port = sd['connector']['port'].to_s
      databag_name = node['wsi_tomcat']['data_bag_config']['bag_name']
      credentials_attribute = node['wsi_tomcat']['data_bag_config']['credentials_attribute']
      tomcat_script_pass = data_bag_item(databag_name, credentials_attribute)[instance]['tomcat_script_pass']

      deployed_apps = []
      success = false
      begin
        open(
          "http://127.0.0.1:#{port}/manager/text/list",
          http_basic_authentication: ['tomcat-script', tomcat_script_pass.to_s]
        ) do |f|
          # Format coming back
          # OK - Listed applications for virtual host localhost
          # /probe:running:1:probe
          # /manager:running:0:manager
          response_arr = f.read.split('\n')
          response_arr.each_with_index do |r, i|
            if i == 0
              success = r[0, 2] == 'OK'
            elsif r[0, 1] == '/'
              deployed_apps.push(r.split(':')[-1, 1])
            end
          end
        end

        # We only care about this if we got a proper response from the server
        if success
          deployed_apps.each do |appname, _attr|
            # Don't delete the manager app if it's supposed to exist
            next unless appname != 'manager' || (appname == 'manager' && node['wsi_tomcat']['disable_manager'])
            next if attributes.application.keys.include?(appname)
            wsi_tomcat_instance instance do
              application_name appname
              action :undeploy_app
            end
          end # deployed_apps.each ...
        end # if success
      rescue
        Chef::Log.info 'Attempting to run undeploy step on an unresponsive server. Continuing...'
      end
    end #  node["wsi_tomcat"]["instances"][instance]["service_definitions"].each ...
  end
end
