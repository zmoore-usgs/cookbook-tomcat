#
# Cookbook Name:: wsi_tomcat
# Recipe:: install_deps
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Install all required dependencies in order to
# install Tomcat

# This IF check prevents two things
# - Installing Java on top of aonther cookbook that may have installed it
# - The Java cookbook used here is not idempotent as it keeps rewriting /etc/environment
if ENV['JAVA_HOME'].empty?
  include_recipe "java"
else
  Chef::Log.info "Java already installed at #{ENV['JAVA_HOME']}"
end

# gcc is needed to compile Tomcat's JSVC module
package "gcc"