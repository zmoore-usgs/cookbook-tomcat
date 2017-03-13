#
# Cookbook Name:: wsi_tomcat
# Recipe:: deploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Deploys application(s) to a specified tomcat instance

tc_node = node['wsi_tomcat']
node['wsi_tomcat']['instances'].each do |instance, attributes|
  next unless attributes.key?('application')
  next unless -> { Helper::TomcatInstance.ready?(node, instance) }

  port = Helper::TomcatInstance.ports(node, instance)[0]
  attributes.application.each do |application, application_attributes|
    tomcat_application application do
      instance_name instance
      version application_attributes.member?('version') ? application_attributes['version'] : ''
      location application_attributes['location']
      path application_attributes['path']
      type application_attributes['type']
      action :deploy
    end
  end

  next unless tc_node['deploy']['remove_unlisted_applications']
  databag_name = tc_node['data_bag_config']['bag_name']
  credentials_attribute = tc_node['data_bag_config']['credentials_attribute']
  tomcat_script_pass = data_bag_item(databag_name, credentials_attribute)[instance]['tomcat_script_pass']

  begin
    deployed_apps = Helper::ManagerClient.get_deployed_applications(port, tomcat_script_pass)
    deployed_apps.each do |path, _state, _session_count, name|
      version = name.split('#').length > 1 ? name.split('#')[-1] : ''
      name = name.split('#').length > 1 ? name.split('#')[1] : name
      # Don't delete the manager app
      next unless name != 'manager'
      next if attributes.application.keys.include?(name)
      tomcat_application name do
        instance_name instance
        version version
        path path
        action :undeploy
      end
    end
  rescue => e
    Chef::Log.error(e)
    return false
  end
end
