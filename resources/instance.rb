actions :create, :delete
default_action :create

attribute :name, 
  :name_attribute => true, 
  :kind_of        => String,
  :required       => true,
  :regex          => /^[a-zA-Z]+$/
attribute :port, 
  :kind_of  => Fixnum,
  :required => true
attribute :ssl,
  :kind_of => Hash,
  :default => {
    :enabled => false,
    :port => NilClass
  }
attribute :tomcat_home,
  :kind_of => String,
  :default => node[:wsi_tomcat][:user][:home_dir]
  
attr_accessor :exists  
