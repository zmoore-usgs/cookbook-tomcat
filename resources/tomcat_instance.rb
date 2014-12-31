actions :create, :delete
default_action :create

attribute :instance_name, 
  :name_attribute => true, 
  :kind_of        => String,
  :required       => true,
  :regex          => /^[a-zA-Z]+$/
attribute :port_number, 
  :kind_of  => Fixnum,
  :required => true
attribute :ssl_enabled,
  :kind_of => [ TrueClass, FalseClass ],
  :default => false
attribute :home,
  :kind_of => String,
  :regex          => /^[a-zA-Z]+$/,
  :default => "/opt/tomcat"
  
attr_accessor :exists  
