actions :create, :start, :stop, :restart, :deploy_app
default_action :create

# Used in: create, start, stop, restart, deploy_app
# Is optional: false
# The name of the tomcat instance. 
attribute :name, 
  :name_attribute => true, 
  :kind_of        => String,
  :required       => true,
  :regex          => /^[a-zA-Z]+$/
  
# Used in: create
# Is optional: false
# The port number that the instance will be assigned to
attribute :service_definitions, 
  :kind_of  => [Array]
    
# Used in: create
# Is optional: true
# Whether CORS will be enabled. False by default 
attribute :cors,
  :kind_of => Hash,
  :default => {
    :enabled => false
  }
  
# Used in: create
# Is optional: true
# Where the tomcat home directory is located. "/opt/tomcat" by default
attribute :tomcat_home,
  :kind_of => String,
  :default => node["wsi_tomcat"]["user"]["home_dir"]
  
# Used in: create
# Is optional: true
# Whether the server will start immediately after installation. Default is true
attribute :auto_start,
  :kind_of => [TrueClass, FalseClass],
  :default => true
  
# Used in: create, deploy_app
# Is optional: true
# An array of strings to add to the server
fqdn = node["fqdn"]
attribute :server_opts,
  :kind_of => [Array, String],
  :default => lazy { |r| [
    "XX:HeapDumpPath=$CATALINA_HOME/heapdumps/#{fqdn}/#{r.name}"
    ]}

# Used in: deploy_app
# Is optional: false
# When deploying the application, the final name of the app
attribute :application_name,
  :kind_of => String
  
attr_accessor :exists