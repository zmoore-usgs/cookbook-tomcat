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

instances.each do |instance, attributes|
  attributes.application.each do |application, app_attributes|
    if app_attributes.has_key?("context")
      conf_path = "#{tomcat_home}/instance/#{instance}/conf/#{context_xml}"
      
      original_resources    = app_attributes[:context].fetch(:resources, [])
      original_environments = app_attributes[:context].fetch(:environments, [])
      resources             = ContextHelper.normalize_resources(original_resources)
      environments          = ContextHelper.normalize_environments(original_environments)
      
      template conf_path do
        owner tomcat_user
        group tomcat_group
        source "instances/conf/#{context_xml}.erb"
        sensitive true
        variables(
        :application  => application,
        :resources    => resources,
        :environments => environments
        )
      end

    end
  end
end
