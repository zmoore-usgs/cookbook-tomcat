resource_name :tomcat_application

default_action :deploy

property  :version,
          [String, NilClass],
          default: '',
          desired_state: false

property  :location,
          String,
          desired_state: false,
          callbacks: {
            'Location may not be empty' => lambda do |v|
              !v.to_s.strip.empty?
            end
          }

property  :path,
          String,
          required: true,
          desired_state: false,
          callbacks: {
            'Path may not be empty' => lambda do |v|
              !v.to_s.strip.empty?
            end
          }

property  :tag,
          String,
          desired_state: false

property  :instance_name,
          String,
          required: true,
          desired_state: false,
          default: 'default',
          callbacks: {
            'Tomcat instance name may not be empty' => lambda do |v|
              !v.to_s.strip.empty?
            end,
            'Instance is not defined in Chef attributes' => lambda do |v|
              instances = node['wsi_tomcat']['instances']
              instances.key?(v)
            end
          }

property  :instance_script_pass,
          String

property  :instance_port,
          Integer

property  :deployed,
          [TrueClass, FalseClass]

property  :deployed_apps,
          Array

property  :type,
          String,
          equal_to: %w[war xml dir],
          desired_state: false,
          default: 'war'

action_class do
  def full_name
    full_name = new_resource.name.dup
    full_name << "###{new_resource.version}" unless new_resource.version.to_s.strip.empty?
  end

  def application_deployed?
    applications = Helper::ManagerClient.get_deployed_applications(new_resource.instance_port, new_resource.instance_script_pass).map { |y| y[3] }
    full_name = new_resource.name.dup
    full_name << "###{new_resource.version}" unless version.to_s.strip.empty?
    applications.include?(full_name)
  end
end

load_current_value do
  instance_port Helper::TomcatInstance.ports(node, instance_name)[0]
  instance_script_pass Helper::TomcatInstance.script_pass(node, instance_name)

  Chef::Log.info("Checking if Tomcat instance #{instance_name} is ready")
  wait_time = node['wsi_tomcat']['instances']['default']['ready_check_timeout']
  unless Helper::TomcatInstance.ready?(node, instance_name, wait_time)
    raise "Tomcat instance #{instance_name} is not running"
  end

  deployed_apps Helper::ManagerClient.get_deployed_applications(instance_port, instance_script_pass)
  full_name = name.dup
  full_name << "###{version}" unless version.to_s.strip.empty?
  deployed_app_names = deployed_apps.map { |y| y[3] }
  deployed deployed_app_names.include?(full_name)
end

# Deploys an application
#
action :deploy do
  location = new_resource.location
  type = new_resource.type
  instance_name = new_resource.instance_name
  name = new_resource.name
  version = new_resource.version
  path = new_resource.path

  unless Helper::TomcatInstance.instance_exists?(node, instance_name)
    Chef::Log.info "Tomcat instance #{instance_name} does not et exist"
    return true
  end

  if location.to_s.strip.empty?
    Chef::Application.fatal!('tomcat_application resource deploy action requires a location')
  end

  if type.to_s.strip.empty?
    Chef::Application.fatal!('tomcat_application resource deploy action requires a type')
  end

  artifact_directory = ::File.join(node['wsi_tomcat']['user']['home_dir'], 'instance', instance_name, 'artifacts')
  artifact_filename = "#{name}#{'_' + version unless version.to_s.strip.empty?}.#{type}"
  artifact_destination = ::File.join(artifact_directory, artifact_filename)

  if ::File.exist?(artifact_destination)
    Chef::Log.info "Application #{name} already deployed"
    return true
  end

  Chef::Log.info("Deploying #{full_name} at #{path} from #{location}")

  tomcat_user = node['wsi_tomcat']['user']['name']
  tomcat_group = node['wsi_tomcat']['user']['group']

  directory artifact_directory do
    owner tomcat_user
    group tomcat_group
  end

  remote_file artifact_destination do
    source location
    owner tomcat_user
    group tomcat_group
    backup false
  end

  webapps_directory = ::File.join(node['wsi_tomcat']['user']['home_dir'], 'instance', instance_name, 'webapps')
  webapps_filename = "#{name}.#{type}"
  webapps_destination = ::File.join(webapps_directory, webapps_filename)

  bash 'copy_war_file' do
    cwd artifact_directory
    user tomcat_user
    code <<-EOF
	  cp #{artifact_filename} #{webapps_destination}
	EOF
  end
end

# Undeploys an application
#
action :undeploy do
  instance_name = new_resource.instance_name
  instance_port = new_resource.instance_port
  instance_script_pass = new_resource.instance_script_pass
  path = new_resource.path
  version = new_resource.version

  unless Helper::TomcatInstance.instance_exists?(node, instance_name)
    Chef::Log.info "Tomcat instance #{instance_name} does not et exist"
    return true
  end

  if application_deployed?
    Chef::Log.info("Undeploying #{name}###{version} at #{path}")
    Helper::ManagerClient.undeploy_application(instance_port, instance_script_pass, path, version)
  else
    Chef::Log.info("Application #{name}###{version} at #{path} not deployed")
  end
end

# Reloads an application
#
# @todo Provide the ability to reload applications when needed
action :reload do
end
