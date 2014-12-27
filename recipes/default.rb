#
# Cookbook Name:: wsi_tomcat
# Recipe:: default
#

include_recipe "wsi_tomcat::create_group"

include_recipe "wsi_tomcat::create_user"
