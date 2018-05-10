# TODO: These methods are way too long and complicated. Run rubocop to get a feel.
provides :tomcat_instance

def whyrun_supported?
  true
end

# Used to interact with Tomcat Manager via REST API
require 'open-uri'

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "Tomcat instance #{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_tomcat_instance
    end
  end
end

action :remove do
  if @current_resource.exists
    converge_by("Remove #{@new_resource}") do
      remove_tomcat_instance?(current_resource.name)
    end
  else
    Chef::Log.info "Tomcat instance #{@new_resource} does not exist - nothing to do."
  end
end

action :start do
  if @current_resource.exists
    if started?(current_resource.name)
      Chef::Log.info "Tomcat instance #{@new_resource} already started - nothing to do."
    else
      converge_by("Start #{@new_resource}") do
        cmd_str = "/sbin/service tomcat start #{current_resource.name}"
        execute cmd_str do
          user 'root'
        end
      end
    end
  else
    Chef::Log.info "Tomcat instance #{@new_resource} does not exist."
  end
end

action :stop do
  if @current_resource.exists
    if started?(current_resource.name)
      converge_by("Stop #{@new_resource}") do
        cmd_str = "/sbin/service tomcat stop #{current_resource.name}"
        execute cmd_str do
          user 'root'
        end
      end
    else
      Chef::Log.info "Tomcat instance #{@new_resource} already started - nothing to do."
    end
  else
    Chef::Log.info "Tomcat instance #{@new_resource} does not exist."
  end
end

action :restart do
  if @current_resource.exists
    converge_by("Restart #{@new_resource}") do
      cmd_str = "/sbin/service tomcat restart #{current_resource.name}"
      execute cmd_str do
        user 'root'
      end
    end
  else
    Chef::Log.info "Tomcat instance #{@new_resource} does not exist."
  end
end

def load_current_resource
  @current_resource = Chef::ResourceResolver.resolve(:tomcat_instance).new(@new_resource.name, run_context)
  @current_resource.name(@new_resource.name)
  @current_resource.service_definitions(@new_resource.service_definitions)
  @current_resource.cors(@new_resource.cors)
  @current_resource.tomcat_home(@new_resource.tomcat_home)
  @current_resource.server_opts(@new_resource.server_opts)
  @current_resource.setenv_opts(@new_resource.setenv_opts)
  @current_resource.auto_start(@new_resource.auto_start)
  @current_resource.application_name(@new_resource.application_name)
  @current_resource.exists = instance_exists?(@current_resource.name)
end

def instance_exists?(name)
  Chef::Log.debug "Checking to see if Tomcat instance '#{name}' exists"
  instances_home = ::File.expand_path('instance', current_resource.tomcat_home)
  instance_home = ::File.expand_path(name, instances_home)
  ::File.exist?(instance_home) && ::File.directory?(instance_home)
end

def remove_tomcat_instance?(name)
  return false unless instance_exists?(name)
  if started?(name)
    cmd_str = "/sbin/service tomcat stop #{name}"
    execute cmd_str do
      user 'root'
      ignore_failure true # This is just a convenience to try and stop the resource before deleting it
    end
  end

  # Delete the instance directory
  instances_home = ::File.expand_path('instance', current_resource.tomcat_home)
  instance_home = ::File.expand_path(name, instances_home)
  directory instance_home do
    recursive true
    action :delete
  end
end

def application_exists?(name)
  tomcat_home_dir        = node['wsi_tomcat']['user']['home_dir']
  instances_dir          = ::File.expand_path('instance', tomcat_home_dir)
  instance_dir           = ::File.expand_path(current_resource.name, instances_dir)
  webapps_dir            = ::File.expand_path('webapps', instance_dir)
  war_name               = ::File.expand_path("#{name}.war", webapps_dir)

  ::File.exist?(war_name)
end

def started?(name)
  Chef::Log.debug "Checking to see if Tomcat instance '#{name}' is started"
  cmd_str = "/sbin/service tomcat status #{name}"
  cmd = Mixlib::ShellOut.new(cmd_str)
  matcher = Regexp.new("(#{name}).*(is running).*", Regexp::IGNORECASE)
  cmd.run_command
  matcher.match(cmd.stdout)
end

# will check for ssl=true and load/create keys from encrypted data_bags
def load_service_definitions_and_keys(service_definitions)
  built_service_definitions = []
  home_dir = node['wsi_tomcat']['user']['home_dir']
  user = node['wsi_tomcat']['user']['name']
  group = node['wsi_tomcat']['group']['name']
  keystore_password = ''

  service_definitions.each do |d|
    new_def = d
    name = new_def['name']
    Chef::Log.info "Found service_definition #{name}"

    if new_def['ssl_connector']['enabled']
      ssl_config = new_def['ssl_connector']
      remote_cert_file = ssl_config['ssl_cert_file']
      remote_key_file = ssl_config['ssl_key_file']
      wsi_tomcat_keys_data_bag = ssl_config['wsi_tomcat_keys_data_bag']
      wsi_tomcat_keys_data_item = ssl_config['wsi_tomcat_keys_data_item']
      trust_certs = ssl_config['trust_certs']
      decrypted_keystore_data_bag = data_bag_item(wsi_tomcat_keys_data_bag, wsi_tomcat_keys_data_item)
      keystore_password = decrypted_keystore_data_bag['keystore_password']
      ssl_dir = "#{home_dir}/ssl"
      local_certificate_location = "#{ssl_dir}/#{name}.localhost.crt"
      local_keystore_location = "#{ssl_dir}/#{name}.localhost.key"

      if !remote_cert_file.nil? && !remote_cert_file.empty? && !remote_key_file.nil? && !remote_key_file.empty?
        # Use provided certificates
        remote_file local_certificate_location do
          source remote_cert_file
          owner user
          group group
          mode 00600
          sensitive true
        end

        remote_file local_keystore_location do
          source remote_key_file
          owner user
          group group
          mode 00600
          sensitive true
        end
      else
        # Generate certificates
        org_unit = ssl_config['org_unit']
        org = ssl_config['org']
        locality = ssl_config['locality']
        state = ssl_config['state']
        country = ssl_config['country']
        host = node['fqdn']
        if !ssl_config['name'].nil? && !ssl_config['name'].empty?
          host =  ssl_config['name']
        end

        execute 'Create keystore' do
          command "/usr/bin/keytool -genkey -noprompt -keystore #{local_keystore_location}  -alias '#{name}' -keyalg RSA -keypass #{keystore_password} -storepass #{keystore_password} -dname 'CN=#{host}, OU=#{org_unit}, O=#{org}, L=#{locality}, S=#{state}, C=#{country}'"
          sensitive true
          not_if { ::File.exist?(local_keystore_location) }
        end
      end

      # create keystore from the key/crt
      bash 'make_keystore' do
        cwd ssl_dir
        code <<-EOH
        openssl pkcs12 -export -name #{name}-localhost -in #{name}.localhost.crt -inkey #{name}.localhost.key -out #{name}.p12 -password pass:#{keystore_password} -passin pass:#{keystore_password} -passout pass:#{keystore_password}
        keytool -importkeystore -destkeystore #{name}.jks -srckeystore #{name}.p12 -srcstoretype pkcs12 -alias #{name}-localhost -srcstorepass #{keystore_password} -deststorepass #{keystore_password}
        EOH
        sensitive true
        not_if { ::File.exist?("#{ssl_dir}/#{name}.jks") }
      end

      # create truststore
      bash 'make_truststore' do
        cwd ssl_dir
        code <<-EOH
        cp #{node['java']['java_home']}/jre/lib/security/cacerts #{ssl_dir}/truststore
        keytool -storepasswd -keystore truststore -storepass changeit -new #{keystore_password}
        EOH
        sensitive true
        not_if { ::File.exist?("#{ssl_dir}/truststore") }
      end

      # add each cert to trust store
      trust_certs.each do |ts|
        host = ts['name']
        location = ts['path']

        if !location.nil? && !location.empty?
          # write cert to file
          remote_file "#{ssl_dir}/#{host}.#{name}.crt" do
            source location
            owner user
            group group
            mode 00600
            sensitive true
            notifies :run, 'bash[make_keystore_from_new_file]', :delayed
            not_if { ::File.exist?("#{ssl_dir}/#{host}.#{name}.crt") }
          end

          bash 'make_keystore_from_new_file' do
            cwd ssl_dir
            code <<-EOH
            keytool -import -noprompt -trustcacerts -alias #{host} -file #{ssl_dir}/#{host}.#{name}.crt -keystore truststore -srcstorepass #{keystore_password} -deststorepass #{keystore_password}
            EOH
            sensitive true
            action :nothing
          end
        else
          # Create CRT
          bash 'make_keystore' do
            cwd ssl_dir
            code <<-EOH
            keytool -import -noprompt -trustcacerts -alias #{host} -file #{ssl_dir}/#{host}.#{name}.crt -keystore truststore -srcstorepass #{keystore_password} -deststorepass #{keystore_password}
            EOH
            sensitive true
            not_if { ::File.exist?("#{ssl_dir}/#{host}.Catalina.crt") }
          end
        end
      end

    end

    built_service_definitions.push(new_def)
  end

  {
    'service_definitions' => built_service_definitions,
    'keystore_password' => keystore_password
  }
end

def create_tomcat_instance
  name                  = current_resource.name
  sd_keys               = load_service_definitions_and_keys(
    node['wsi_tomcat']['instances'][name]['service_definitions']
  )
  service_definitions   = sd_keys['service_definitions']
  keystore_password     = sd_keys['keystore_password']
  server_opts           = Array.new(current_resource.server_opts)
  setenv_opts           = Array.new(current_resource.setenv_opts)
  tomcat_home           = node['wsi_tomcat']['user']['home_dir']
  fqdn                  = node['fqdn']
  cors                  = current_resource.cors
  auto_start            = current_resource.auto_start
  tomcat_user           = node['wsi_tomcat']['user']['name']
  tomcat_group          = node['wsi_tomcat']['group']['name']
  manager_archive_name  = node['wsi_tomcat']['archive']['manager_name']
  archives_home         = ::File.expand_path('archives', tomcat_home)
  manager_archive_path  = ::File.expand_path(manager_archive_name, archives_home)
  instances_home        = ::File.expand_path('instance', tomcat_home)
  instance_home         = ::File.expand_path(name, instances_home)
  instance_webapps_path = ::File.expand_path('webapps', instance_home)
  instance_bin_path     = ::File.expand_path('bin', instance_home)
  tomcat_bin_path       = ::File.expand_path('bin', tomcat_home)
  instance_conf_path    = ::File.expand_path('conf', instance_home)
  tomcat_init_script    = "tomcat-#{name}"
  default_cors          = {
    'enabled'          => true,
    'allowed'          => {
      'origins'        => '*',
      'methods'        => %w[GET POST HEAD OPTIONS],
      'headers'        => [
        'Origin',
        'Accept',
        'X-Requested-With',
        'Content-Type',
        'Access-Control-Request-Method',
        'Access-Control-Request-Headers'
      ]
    },
    'exposed_headers'     => [],
    'preflight_maxage'    => 1800,
    'support_credentials' => true,
    'filter' => '/*'
  }

  instance_conf_files = %w[
    catalina.policy
    catalina.properties
    logging.properties
    context.xml
    logging.properties
    server.xml
    tomcat-users.xml
    web.xml
  ]

  server_opts.push("-Djavax.net.ssl.trustStore=#{tomcat_home}/ssl/truststore")
  server_opts.push("-Djavax.net.ssl.trustStorePassword=#{keystore_password}")

  databag_name = node['wsi_tomcat']['data_bag_config']['bag_name']
  credentials_attribute = node['wsi_tomcat']['data_bag_config']['credentials_attribute']

  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
  elsif search(databag_name, "id:#{credentials_attribute}").any?
    credentials = data_bag_item(databag_name, credentials_attribute)
    tomcat_admin_pass = credentials[name]['tomcat_admin_pass']
    tomcat_script_pass = credentials[name]['tomcat_script_pass']
    tomcat_jmx_pass = credentials[name]['tomcat_jmx_pass']
  end

  Chef::Log.info "Creating Instance #{name}"

  Chef::Log.info "Creating Instance Directory #{instance_home}"
  directory instance_home do
    owner tomcat_user
    group tomcat_group
    action :create
  end

  # Create the required directories in the instance directory
  %w[bin conf lib logs temp webapps work].each do |dir|
    Chef::Log.info "Creating Instance subdirectory #{dir}"
    directory ::File.expand_path(dir, instance_home) do
      owner tomcat_user
      group tomcat_group
      action :create
    end
  end

  # Make sure that all CORS values are set
  cors = default_cors.merge(cors) if cors['enabled']

  instance_conf_files.each do |tpl|
    Chef::Log.info "Creating configuration file #{tpl}"
    template ::File.expand_path(tpl, instance_conf_path) do
      owner tomcat_user
      group tomcat_group
      source "instances/conf/#{tpl}.erb"
      sensitive true
      variables(
        version: node['wsi_tomcat']['version'],
        disable_admin_users: node['wsi_tomcat']['instances'][name]['user']['disable_admin_users'],
        disable_manager: node['wsi_tomcat']['disable_manager'],
        tomcat_admin_pass: tomcat_admin_pass,
        tomcat_script_pass: tomcat_script_pass,
        tomcat_jmx_pass: tomcat_jmx_pass,
        service_definitions: service_definitions,
        cors: cors,
        keystore_password: keystore_password
      )
    end
  end

  %w[start stop].each do |bin_file|
    Chef::Log.info "Templating bin file #{bin_file}"
    template "#{tomcat_bin_path}/#{bin_file}_#{name}" do
      source "instances/bin/#{bin_file}.erb"
      owner tomcat_user
      group tomcat_group
      mode 0744
      variables(
        instance_name: name,
        tomcat_home: tomcat_home
      )
    end
  end

  template "#{instance_bin_path}/setenv.sh" do
    source 'instances/bin/setenv.sh.erb'
    owner tomcat_user
    group tomcat_group
    mode 0744
    variables(
      setenv_opts: setenv_opts
    )
    sensitive true
  end

  template "#{instance_bin_path}/catalinaopts.sh" do
    source 'instances/bin/catalinaopts.sh.erb'
    owner tomcat_user
    group tomcat_group
    variables(
      server_opts: server_opts
    )
    mode 0744
    sensitive true
  end

  template "Install #{tomcat_init_script} script" do
    path "/etc/init.d/#{tomcat_init_script}"
    source 'instances/tomcat-initscript.sh.erb'
    owner 'root'
    group 'root'
    variables(
      instance_name: name,
      tomcat_home: tomcat_home
    )
    mode 0755
  end

  directory 'Create heapdumps directory' do
    owner tomcat_user
    group tomcat_group
    path "#{tomcat_home}/heapdumps/#{fqdn}/#{name}"
    recursive true
  end

  unless node['wsi_tomcat']['disable_manager']
    execute "Create manager application for #{name}" do
      cwd instance_webapps_path
      user tomcat_user
      group tomcat_group
      command "/bin/tar -xvf #{manager_archive_path}"
      not_if ::File.exist?(::File.expand_path('manager', instance_webapps_path))
    end
  end

  # TODO: This can probably be symlinked to the base tomcat directory
  execute "Copy tomcat-juli to instance #{name}" do
    user tomcat_user
    group tomcat_group
    command "/bin/cp #{archives_home}/tomcat-juli.jar #{instance_bin_path}"
    not_if ::File.exist?(::File.expand_path('tomcat-juli.jar', instance_bin_path))
  end

  execute 'Chkconfig the init script for this instance' do
    user 'root'
    group 'root'
    command "/sbin/chkconfig --level 234 #{tomcat_init_script} on"
    not_if "chkconfig | grep -q '#{tomcat_init_script}'"
  end

  execute "Start tomcat instance #{name}" do
    command "/bin/bash service tomcat start #{name}"
    user 'root'
    group 'root'
    only_if { auto_start }
  end
end
