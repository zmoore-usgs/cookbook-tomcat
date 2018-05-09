#
# Cookbook Name:: wsi_tomcat
# Recipe:: deploy_application
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Deploys application(s) to a specified tomcat instance

tc_node = node['wsi_tomcat']
node.run_state['wsi_tomcat'] = {
  'instances' => {}
}

node['wsi_tomcat']['instances'].each do |instance, attributes|
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

  # If this instance is not set up to remove applications not in the application
  # list, move on
  next unless tc_node['deploy']['remove_unlisted_applications']

  databag_name = tc_node['data_bag_config']['bag_name']
  credentials_attribute = tc_node['data_bag_config']['credentials_attribute']
  tomcat_script_pass = data_bag_item(databag_name, credentials_attribute)[instance]['tomcat_script_pass']

  begin
    # Protects against this block running before a Tomcat instance exists
    # This really only matters since Helper::ManagerClient.get_deployed_applications
    # does not check for an instance existing and this spouts out an error
    # into the logs during cookbook compilation during the first Chef run
    next unless Helper::TomcatInstance.instance_exists?(node, instance)

    port = Helper::TomcatInstance.ports(node, instance)[0]
    deployed_apps = Helper::ManagerClient.get_deployed_applications(port, tomcat_script_pass)
    deployed_apps.each do |path, _state, _session_count, name|
      version = name.split('#').length > 1 ? name.split('#')[-1] : ''
      # Don't delete the manager app
      next unless name != 'manager'
      next if attributes['application'].keys.include?(name)
      next unless running

      # TODO : We can probably use the Chef::Helper::ManagerClient to perform this
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
