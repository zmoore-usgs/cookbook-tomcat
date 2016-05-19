#
# Cookbook Name:: wsi_tomcat
# Recipe:: create_tomcat_instances
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Deploys described Tomcat instances and optionally undeploys any instances
#             that may have previously been deployed but are no longer descripted

tomcat_home = node["wsi_tomcat"]["user"]["home_dir"]
instances_dir = "#{tomcat_home}/instance"

if node["wsi_tomcat"]["deploy"]["remove_unlisted_instances"] && File.directory?(instances_dir)
  instance_dirs = Array.new 
  Dir.entries(instances_dir).each do |f|
    unless f == "." || f == ".." || ! File.directory?("#{instances_dir}/#{f}")
      instance_dirs.push(f)
    end
  end
  instance_names = node["wsi_tomcat"]["instances"].keys
  instance_dirs.each do |inst_dir|
    if ! instance_names.include? inst_dir
      # Found a possible Tomcat instance that is not listed in the config.
      wsi_tomcat_instance inst_dir do
        action :remove
      end
    end

  end
end

node["wsi_tomcat"]["instances"].each do |name, attributes|
  service_definitions = attributes.service_definitions
  server_opts = attributes.server_opts
  cors = attributes.key?("cors") ? attributes.cors : { :enabled => false }
  auto_start = attributes.key?("auto_start") ? attributes.auto_start : true

  wsi_tomcat_instance name do
    service_definitions service_definitions
    server_opts server_opts
    tomcat_home tomcat_home
    cors cors
    auto_start auto_start
  end
end
