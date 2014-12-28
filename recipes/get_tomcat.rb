#
# Cookbook Name:: wsi_tomcat
# Recipe:: get_tomcat
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Gets and unpacks apache tomcat tarball

archive_download_path = "/opt/apache-tomcat-" + node[:wsi_tomcat][:version] + ".tar.gz"
group_name = node[:wsi_tomcat][:group][:name]
user_name = node[:wsi_tomcat][:user][:name]
mirrors = node[:wsi_tomcat][:file][:mirrors]
checksum = node[:wsi_tomcat][:file][:checksum]

remote_file archive_download_path do
  owner user_name
  checksum ""
  source mirrors
  action :create_if_missing
end


