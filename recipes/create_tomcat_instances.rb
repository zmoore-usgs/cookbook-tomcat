#
# Cookbook Name:: wsi_tomcat
# Recipe:: create_tomcat_instances
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: 
tomcat_home = node[:wsi_tomcat][:user][:home_dir]

node[:wsi_tomcat][:instances].each do |name, attributes|
  default_cors = {
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
  port = attributes.port
  ssl  = attributes.key?("ssl") ? attributes.ssl  : { :enabled => false }
  cors = attributes.key?("cors") ? attributes.cors : { :enabled => false }
  
  puts name
  puts ssl
  puts cors
  
  wsi_tomcat_instance name do
    port port
    ssl ssl
    tomcat_home tomcat_home
    cors cors
  end
end
