#
# Cookbook Name:: wsi_tomcat
# Recipe:: undeploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Undeploys application(s) from a specified tomcat instance

tc_node = node['wsi_tomcat']

tc_node['instances'].each do |instance, attributes|
  next unless Helper::TomcatInstance.instance_exists?(node, instance)
  next unless attributes.key?('application')
  next unless tc_node['deploy']['remove_unlisted_applications']

  databag_name = tc_node['data_bag_config']['bag_name']
  credentials_attribute = tc_node['data_bag_config']['credentials_attribute']
  tomcat_script_pass = data_bag_item(databag_name, credentials_attribute)[instance]['tomcat_script_pass']
  max_attempts = instance['ready_check_timeout_attempts']
  check_timeout = instance['ready_check_timeout_wait']
  next unless Helper::TomcatInstance.ready?(node, instance, max_attempts, check_timeout)
  port = Helper::TomcatInstance.ports(node, instance)[0]
  deployed_apps = Helper::ManagerClient.get_deployed_applications(port, tomcat_script_pass, max_attempts, check_timeout)
  deployed_apps.each do |path, _state, _session_count, name|
    version = name.split('#').length > 1 ? name.split('#')[-1] : ''
    # Don't delete the manager app
    next unless name != 'manager'
    next if attributes['application'].keys.include?(name)

    # TODO : We can probably use the Chef::Helper::ManagerClient to perform this
    tomcat_application name do
      instance_name instance
      version version
      path path
      action :undeploy
    end
  end
end
