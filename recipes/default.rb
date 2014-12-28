#
# Cookbook Name:: wsi_tomcat
# Recipe:: default
#
include_recipe "java"

include_recipe "wsi_tomcat::create_group"

include_recipe "wsi_tomcat::create_user"

include_recipe "wsi_tomcat::get_tomcat"
