#
# Cookbook Name:: wsi_tomcat
# Recipe:: create_tomcat_base
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Creates the Tomcat base directory structure
#
# TODO This recipe should be refactored since it's using
# resource cloning
# http://scottwb.com/blog/2014/01/24/defeating-the-infamous-chef-3694-warning/

user_name = node[:wsi_tomcat][:user][:name]
group_name = node[:wsi_tomcat][:group][:name]
tomcat_home = node[:wsi_tomcat][:user][:home_dir]
manager_archive_name = node[:wsi_tomcat][:archive][:manager_name]
archives_dir = File.expand_path("archives", tomcat_home)

create_home_dirs = [
  "instance",
  "heapdumps",
  "data",
  "run",
  "share",
  "ssl",
  "ssltmp",
  "archives"
]
delete_home_dirs = [
  "temp",
  "work",
  "webapps"
]
delete_home_files = [
  "LICENSE",
  "NOTICE",
  "RELEASE-NOTES",
  "RUNNING.txt"
]

create_home_dirs.each do |dir|
  directory "create directory #{dir} in tomcat home" do
    path ::File.expand_path(dir, tomcat_home)
    owner user_name
    group group_name
    only_if { File.exists?(tomcat_home)}
  end
end

execute "archive manager webapp" do
  command "/bin/tar -czvf #{File.expand_path(manager_archive_name, archives_dir)} manager"
  user user_name
  group group_name
  cwd File.expand_path("webapps", tomcat_home)
  not_if { File.exists?(File.expand_path(manager_archive_name, archives_dir))}
end

delete_home_dirs.each do |dir|
  full_path  = File.expand_path(dir, tomcat_home);
  
  directory "remove directory #{full_path} in tomcat home" do
    path full_path
    recursive true
    action :delete
  end
end

delete_home_files.each do |file|
  full_path  = File.expand_path(file, tomcat_home);

  file "remove file #{full_path} in tomcat home" do
    path full_path
    action :delete
  end
end