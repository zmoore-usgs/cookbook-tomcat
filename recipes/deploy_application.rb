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

  # All of this code goes into a ruby_block because with Chef 13, code outside of
  # a ruby block begins to get fired off and this will error out because a server
  # does not yet exist
  ruby_block "Deploy applications for #{instance}" do # ~FC014
    block do
      running = Helper::TomcatInstance.ready?(node, instance)
      node.run_state['wsi_tomcat']['instances'][instance] = { 'ready' => running }

      # If the instance isn't ready for me, I don't keep going
      next unless running

      attributes['application'].each do |application, application_attributes|
        # I am not able to use my LWRP resource in the way I would typically in a
        # ruby_block (as tomcat_application) so I am forced to fire it off this way
        # TODO : We can probably use the Chef::Helper::ManagerClient to perform this
        app = Chef::Resource::WsiTomcatApplication.new(application, run_context)
        app.name application
        app.instance_name instance
        app.version application_attributes.member?('version') ? application_attributes['version'] : ''
        app.location application_attributes['location']
        app.path application_attributes['path']
        app.type application_attributes['type']
        app.run_action(:deploy)
      end

      # If this instance is not set up to remove applications not in the application
      # list, move on
      next unless tc_node['deploy']['remove_unlisted_applications']

      databag_name = tc_node['data_bag_config']['bag_name']
      credentials_attribute = tc_node['data_bag_config']['credentials_attribute']
      tomcat_script_pass = data_bag_item(databag_name, credentials_attribute)[instance]['tomcat_script_pass']

      begin
        port = Helper::TomcatInstance.ports(node, instance)[0]
        deployed_apps = Helper::ManagerClient.get_deployed_applications(port, tomcat_script_pass)
        deployed_apps.each do |_path, _state, _session_count, name|
          version = name.split('#').length > 1 ? name.split('#')[-1] : ''
          # Don't delete the manager app
          next unless name != 'manager'
          next if attributes.application.keys.include?(name)
          next unless running

          # As above, in a ruby block I must use this format to call my wsi_tomcat_application
          # LWRP due to ruby_block scope
          # TODO : We can probably use the Chef::Helper::ManagerClient to perform this
          app = Chef::Resource::WsiTomcatApplication.new(name, run_context)
          app.name name
          app.instance_name instance
          app.version version
          app.path _path
          app.run_action(:undeploy)
        end
      rescue => e
        Chef::Log.error(e)
        return false
      end
    end
  end
end
