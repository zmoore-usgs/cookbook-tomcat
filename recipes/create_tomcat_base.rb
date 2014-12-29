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
include_home_dirs = node[:wsi_tomcat][:file][:base_dir][:include]
exclude_home_dirs = node[:wsi_tomcat][:file][:base_dir][:exclude]

include_home_dirs.each do |dir|
  directory "create directory #{dir} in tomcat home" do
    path ::File.expand_path(dir, tomcat_home)
    owner user_name
    group group_name
    only_if { File.exists?(tomcat_home)}
  end
end

exclude_home_dirs.each do |path|
  full_path  = File.expand_path(path, tomcat_home);
  if File.directory?(full_path)
    directory "remove directory #{full_path} in tomcat home" do
      path full_path
      recursive true
      action :delete
    end
  elsif File.file?(full_path)
    file "remove file #{full_path} in tomcat home" do
      path full_path
      action :delete
    end
  end

end