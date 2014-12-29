#
# Cookbook Name:: wsi_tomcat
# Recipe:: default
#
include_recipe "wsi_tomcat::install_deps"

include_recipe "wsi_tomcat::create_group"

include_recipe "wsi_tomcat::create_user"

include_recipe "wsi_tomcat::get_tomcat"

include_recipe "wsi_tomcat::commons_daemon"

include_recipe "wsi_tomcat::create_tomcat_base"

#include_recipe "wsi_tomcat::create_tomcat_instances"

#include_recipe "wsi_tomcat::cleanup_tomcat_base"