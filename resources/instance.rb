actions :create, :start, :stop, :restart
default_action :create

attribute :name, 
  :name_attribute => true, 
  :kind_of        => String,
  :required       => true,
  :regex          => /^[a-zA-Z]+$/
attribute :port, 
  :kind_of  => Fixnum,
  :default => 8080
attribute :ssl,
  :kind_of => Hash,
  :default => {
    :enabled => false
  }
attribute :cors,
  :kind_of => Hash,
  :default => {
    :enabled => false
  }
attribute :tomcat_home,
  :kind_of => String,
  :default => node[:wsi_tomcat][:user][:home_dir]
attribute :auto_start,
  :kind_of => [TrueClass, FalseClass],
  :default => true
attribute :server_opts,
  :kind_of => [Array, String],
  :default => lazy { |r| [
    "server",
    "XX:MaxPermSize=256m",
    "Xmx1024m",
    "XX:+HeapDumpOnOutOfMemoryError",
    "XX:+UseConcMarkSweepGC",
    "XX:+CMSClassUnloadingEnabled",
    "XX:+CMSIncrementalMode",
    "XX:HeapDumpPath=$CATALINA_HOME/heapdumps/#{node.fqdn}/#{r.name}"
    ]}
    
attr_accessor :exists