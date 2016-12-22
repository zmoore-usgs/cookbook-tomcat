#
# Cookbook Name:: wsi_tomcat
# Recipe:: install_apr
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Installs APR library for Tomcat. This must be ran AFTER Tomcat
# has been downloaded and unpackaged. Run this after get_tomcat recipe

package 'gcc'
package 'perl'
package 'make'

mirrors = node['wsi_tomcat']['file']['archive']['mirrors']
apr_version = node['wsi_tomcat']['apr']['apr_version']
group_name = node['wsi_tomcat']['group']['name']
user_name = node['wsi_tomcat']['user']['name']
openssl_version = node['wsi_tomcat']['apr']['openssl_version']
bin_dir = '/opt/tomcat/bin'
unpack_dir = "#{bin_dir}/tomcat-native/"
apr_url_fragment  = "apr/apr-#{apr_version}.tar.gz"
apr_download_path = "#{Chef::Config[:file_cache_path]}/apr-install.tar.gz"
openssl_download_path = "#{Chef::Config[:file_cache_path]}/openssl-install.tar.gz"
apr_unpack_path = "#{Chef::Config[:file_cache_path]}/apr-install"
openssl_unpack_path = "#{Chef::Config[:file_cache_path]}/openssl-install"

apr_mirrors = []
mirrors.each do |base|
  apr_mirrors.push(base + apr_url_fragment)
end

remote_file apr_download_path do
  source apr_mirrors
  action :create_if_missing
end

directory openssl_unpack_path

remote_file openssl_download_path do
  source "https://www.openssl.org/source/openssl-#{openssl_version}.tar.gz"
  action :create_if_missing
end

execute 'unpack OpenSSL source' do
  command "/bin/tar xvf #{openssl_download_path} -C #{openssl_unpack_path} --strip 1"
  only_if { Dir["#{openssl_unpack_path}/*"].empty? }
end

# Do not compile is the library is already installed
execute 'Compile OpenSSL' do
  command './config -fPIC && make depend && make && make install_sw'
  cwd openssl_unpack_path
  not_if { File.directory?('/usr/local/ssl') }
end

directory apr_unpack_path

execute 'unpack Apache APR source' do
  command "/bin/tar xvf #{apr_download_path} -C #{apr_unpack_path} --strip 1"
  only_if { Dir["#{apr_unpack_path}/*"].empty? }
end

# Do not compile is the library is already installed
execute 'Compile Apache APR' do
  command './configure && make && make install'
  cwd apr_unpack_path
  not_if { File.directory?('/usr/local/apr') }
end

directory unpack_dir do
  owner user_name
  group group_name
end

execute 'Unpack tomcat native APR source' do
  command "/bin/tar xvf #{bin_dir}/tomcat-native.tar.gz -C #{unpack_dir} --strip 1"
  only_if { Dir["#{unpack_dir}/*"].empty? }
  user user_name
  group group_name
end

# Do not compile is the library is already installed
execute 'Compile Native APR' do
  command './configure --with-apr=/usr/local/apr --with-ssl=/usr/local/ssl && make && make install'
  cwd openssl_unpack_path
  not_if { File.directory?('/usr/local/apr/lib') }
end

link '/usr/lib/apr' do
  to '/usr/local/apr/lib/'
end
