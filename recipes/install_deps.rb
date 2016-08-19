#
# Cookbook Name:: wsi_tomcat
# Recipe:: install_deps
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Install all required dependencies in order to
# install Tomcat

# gcc is needed to compile Tomcat's JSVC module
package "gcc"
