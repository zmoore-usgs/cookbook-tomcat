#
# Cookbook Name:: wsi_tomcat
# Recipe:: update_context
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Updates context.xml 

instances    = node[:wsi_tomcat][:instances]
tomcat_group = node[:wsi_tomcat][:group][:name]
tomcat_user  = node[:wsi_tomcat][:user][:name]
tomcat_home  = node[:wsi_tomcat][:user][:home_dir]
context_xml  = "context.xml"
r            = []
e            = []
instances.each do |instance, attributes|
  conf_path = "#{tomcat_home}/instance/#{instance}/conf/#{context_xml}"
  
  attributes.application.each do |application, app_attributes|
    if app_attributes.has_key?("context")
      original_resources    = app_attributes[:context].fetch(:resources, [])
      original_environments = app_attributes[:context].fetch(:environments, [])
      
      unless original_resources.empty?
        r.push(ContextHelper.normalize_resources(original_resources))
      end
      
      unless original_environments.empty?
        e.push(ContextHelper.normalize_environments(original_environments))
      end
    end
  end
  
  template conf_path do
    owner tomcat_user
    group tomcat_group
    source "instances/conf/#{context_xml}.erb"
    sensitive true
    variables(
    :resources    => r.flatten,
    :environments => e.flatten
    )
  end
end


