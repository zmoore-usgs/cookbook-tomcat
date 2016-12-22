#
# Cookbook Name:: wsi_tomcat
# Recipe:: download_libs
# Author: Phethala Thongsavanh < thongsav@usgs.gov >
#
# Description: Deploys application(s) to a specified tomcat instance

lib_sources = node['wsi_tomcat']['lib_sources']
tomcat_group = node['wsi_tomcat']['group']['name']
tomcat_user  = node['wsi_tomcat']['user']['name']
tomcat_home = node['wsi_tomcat']['user']['home_dir']

lib_sources.each do |libs|
  Chef::Log.info "Downloading library #{libs['name']} from #{libs['url']}"
  remote_file "#{tomcat_home}/lib/#{libs['name']}" do
    source libs['url'].to_s
    owner tomcat_user
    group tomcat_group
    backup false
    :create
  end
end
