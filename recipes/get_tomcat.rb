#
# Cookbook Name:: wsi_tomcat
# Recipe:: get_tomcat
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Gets and unpacks apache tomcat tarball

tomcat_version = node["wsi_tomcat"]["version"]
tomcat_unpack_dir = "/opt/apache-tomcat-#{tomcat_version}"
archive_download_path = tomcat_unpack_dir + ".tar.gz"
group_name = node["wsi_tomcat"]["group"]["name"]
user_name = node["wsi_tomcat"]["user"]["name"]

mirrors = node["wsi_tomcat"]["file"]["archive"]["mirrors"]
version = node["wsi_tomcat"]["version"];
version_base = version.split(".")[0]
tomcat_url_fragment  = "tomcat/tomcat-#{version_base}/v#{version}/bin/apache-tomcat-#{version}.tar.gz"
mirrors_built = []
mirrors.each do |base| 
  mirrors_built.push(base + tomcat_url_fragment)
end

checksum = node["wsi_tomcat"]["file"]["archive"]["checksum"]
tomcat_base_dir = "/opt/" + user_name

remote_file archive_download_path do
  owner user_name
  checksum checksum
  source mirrors_built
  action :create_if_missing
  notifies :run, "execute[unpack tomcat binary]", :immediately
  notifies :run, "execute[gain rights for base dir]", :immediately
end

execute "unpack tomcat binary" do
  command "/bin/tar xvf #{archive_download_path} -C /opt/"
  cwd "/opt"
  creates tomcat_unpack_dir
  action :nothing
end

execute "gain rights for base dir" do
  command "chown -R #{user_name}:#{group_name} #{tomcat_unpack_dir}"
  user 'root'
  action :nothing
end

link "/opt/tomcat" do
  owner user_name
  group group_name
  to tomcat_unpack_dir
end
