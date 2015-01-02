def whyrun_supported?
  true
end

use_inline_resources



action :create do
  if @current_resource.exists
    Chef::Log.info "Tomcat instance #{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_tomcat_instance
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_tomcat_instance
    end
  else
    Chef::Log.info "Tomcat instance #{ @new_resource } doesnt exist - can't delete."
  end
end

def load_current_resource 
  @current_resource = Chef::Resource::WsiTomcatInstance.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.port(@new_resource.port)
  @current_resource.ssl(@new_resource.ssl)
  @current_resource.cors(@new_resource.cors)
  @current_resource.tomcat_home(@new_resource.tomcat_home)
  @current_resource.server_opts(@new_resource.server_opts)
  @current_resource.auto_start(@new_resource.auto_start)
  if instance_exists?(@current_resource.name)
    @current_resource.exists     = true
  end
end

def instance_exists?(name)
  Chef::Log.debug "Checking to see if Tomcat instance '#{name}' exists"
  instances_home = ::File.expand_path("instance", current_resource.tomcat_home)
  instance_home = ::File.expand_path(name, instances_home)
  ::File.exists?(instance_home) && ::File.directory?(instance_home)
end

def create_tomcat_instance
  name                  = current_resource.name
  port                  = current_resource.port
  ssl                   = current_resource.ssl
  server_opts           = current_resource.server_opts
  tomcat_home           = current_resource.tomcat_home
  cors                  = current_resource.cors
  auto_start            = current_resource.auto_start
  tomcat_user           = node[:wsi_tomcat][:user][:name]
  tomcat_group          = node[:wsi_tomcat][:group][:name]
  manager_archive_name  = node[:wsi_tomcat][:archive][:manager_name]
  archives_home         = ::File.expand_path("archives", tomcat_home)
  manager_archive_path  = ::File.expand_path(manager_archive_name, archives_home)
  instances_home        = ::File.expand_path("instance", tomcat_home)
  instance_home         = ::File.expand_path(name, instances_home)
  instance_webapps_path = ::File.expand_path("webapps", instance_home)
  instance_bin_path     = ::File.expand_path("bin", instance_home)
  instance_conf_path    = ::File.expand_path("conf", instance_home)
  ssl_port              = port + 363 # Default 8443 when regular port is 8080
  ajp_port              = port - 71 # Default port is 8009 when regular port is 8080
  tomcat_init_script    = "tomcat-#{name}"
  default_cors          = {
      :enabled => true,
      :allowed => { 
        :origins => "*",
        :methods => ["GET", "POST", "HEAD", "OPTIONS"],
        :headers => ["Origin", "Accept", "X-Requested-With", "Content-Type", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
      },
      :exposed_headers     => [],
      :preflight_maxage    => 1800,
      :support_credentials => true,
      :filter => "/*"
    }
  instance_conf_files   = [
    "catalina.policy",
    "catalina.properties",
    "logging.properties",
    "context.xml",
    "logging.properties",
    "server.xml",
    "tomcat-users.xml",
    "web.xml"
  ]
  instance_bin_files = [
    "setenv.sh"
  ]
  
  Chef::Log.info "Creating Instance #{name}"
  
  Chef::Log.info "Creating Instance Directory #{instance_home}"
  directory instance_home do
    owner tomcat_user
    group tomcat_group
    action :create
  end
  
  # Create the required directories in the instance directory
  %w{bin conf lib logs temp webapps work}.each do |dir|
    Chef::Log.info "Creating Instance subdirectory #{dir}"
    directory ::File.expand_path(dir, instance_home) do
      owner tomcat_user
      group tomcat_group
      action :create
    end
  end
  
  # Make sure that all CORS values are set
  if cors[:enabled]
    cors = default_cors.merge(cors)
  end
  
  instance_conf_files.each do |tpl|
    Chef::Log.info "Creating configuration file #{tpl}"
    template ::File.expand_path(tpl, instance_conf_path) do
      owner tomcat_user
      group tomcat_group
      source "instances/conf/#{tpl}.erb"
      sensitive true
      variables(
        :tomcat_admin_pass => node[:wsi_tomcat][:instances][name][:user][:tomcat_admin_pass],
        :tomcat_script_pass => node[:wsi_tomcat][:instances][name][:user][:tomcat_script_pass],
        :tomcat_jmx_pass => node[:wsi_tomcat][:instances][name][:user][:tomcat_jmx_pass],
        :port => port,
        :ssl_port => ssl_port,
        :ajp_port => ajp_port,
        :ssl_enabled => ssl[:enabled],
        :cors => cors
      )
    end
  end
  
  instance_bin_files.each do |bin_file|
    Chef::Log.info "Copying bin file #{bin_file}"
    cookbook_file "#{::File.expand_path(bin_file, instance_bin_path)}" do
      source "instances/bin/#{bin_file}"
      owner tomcat_user
      group tomcat_group
      mode 0744
    end
  end
  
  template "#{::File.expand_path('catalinaopts.sh', instance_bin_path)}" do
    source "instances/bin/catalinaopts.sh.erb"
    owner tomcat_user
    group tomcat_group
    variables(
    :server_opts => server_opts
    )
    mode 0744
  end
  
  template "Install #{tomcat_init_script} script" do
    path "/etc/init.d/#{tomcat_init_script}"
    source "instances/tomcat-initscript.sh.erb"
    owner "root"
    group "root"
    variables(
    :instance_name => name,
    :tomcat_home => tomcat_home
    )
    mode 0755
  end
  
  execute "Create manager application for #{name}" do
    cwd instance_webapps_path
    user tomcat_user
    group tomcat_group
    command "/bin/tar -xvf #{manager_archive_path}"
    not_if ::File.exists?(::File.expand_path("manager", instance_webapps_path))
  end
  
  # TODO This can probably be symlinked to the base tomcat directory
  execute "Copy tomcat-juli to instance #{name}" do
    user tomcat_user
    group tomcat_group
    command "/bin/cp #{archives_home}/tomcat-juli.jar #{instance_bin_path}"
    not_if ::File.exists?(::File.expand_path("tomcat-juli.jar", instance_bin_path))
  end
  
  execute "Chkconfig the init script for this instance" do
    user "root"
    group "root"
    command "/sbin/chkconfig --level 234 #{tomcat_init_script} on"
    not_if "chkconfig | grep -q '#{tomcat_init_script}'"
  end
  
  execute "Start tomcat instance #{name}" do
    command "/bin/bash service tomcat start #{name}"
    user "root"
    group "root"
    only_if { auto_start }
  end
  new_resource.updated_by_last_action(true)
end

def delete_tomcat_instance
  instances_home = ::File.expand_path("instance", current_resource.tomcat_home)
  instance_home  = ::File.expand_path(name, instances_home)
  directory instance_home do
    recursive true
    action :delete
  end
  new_resource.updated_by_last_action(true)
end

