require 'open-uri'

class Chef
  class Recipe
    # Cookbook Name:: wsi_tomcat
    # Class:: ManagerClient
    # Author: Ivan Suftin < isuftin@usgs.gov >
    #
    # Description: Helper functions to communicate with the Tomcat manager application
    class ManagerClient
      # Communicates with the running Tomcat container at a given port and returns
      # an array of application names currently deployed on the server. If a
      # communication error occurs, an exception is thrown.
      def self.get_deployed_applications(port, tomcat_script_pass)
        deployed_apps = []
        begin
          open(
            "http://127.0.0.1:#{port}/manager/text/list",
            http_basic_authentication: ['tomcat-script', tomcat_script_pass.to_s]
          ) do |f|
            # Format coming back
            # OK - Listed applications for virtual host localhost
            # /probe:running:1:probe
            # /manager:running:0:manager
            response = f.read
            response_arr = response.split(/\n/)
            response_arr.each_with_index do |r, i|
              if i.zero?
                raise response unless r[0, 2] == 'OK'
              elsif r[0, 1] == '/'
                deployed_apps.push(r.split(':')[-1, 1][0])
              end
            end
          end
          return deployed_apps
        rescue => e
          Chef::Log.error "Error occurred when communicating with Tomcat server: #{e}"
          raise
        end
      end

      # Communicates with the running Tomcat container at a given port and attempts
      # to undeploy an application. If a communication error occurs, or the application
      # cannot be undeployed for some reason, an exception is thrown. Otherwise,
      # the server response is returned
      def self.undeploy_application(port, tomcat_script_pass, application_name)
        puts "HERE!!!!"
        open(
          "http://127.0.0.1:#{port}/manager/text/undeploy?path=/#{application_name}",
          http_basic_authentication: ['tomcat-script', tomcat_script_pass.to_s]
        ) do |f|
          # First result will be the response for this command
          response = f.read
          status = response.split(' ')[0]
          raise response unless status == 'OK'
          return response
        end
      rescue => e
        Chef::Log.error "Error occurred when communicating with Tomcat server: #{e}"
        raise
      end
    end
  end
end
