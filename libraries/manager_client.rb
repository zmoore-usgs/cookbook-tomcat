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
      # communication error occurs, an exception is thrown
      def self.get_deployed_applications(port, tomcat_script_pass)
        deployed_apps = []
        success = false
        begin
          open(
            "http://127.0.0.1:#{port}/manager/text/list",
            http_basic_authentication: ['tomcat-script', tomcat_script_pass.to_s]
          ) do |f|
            # Format coming back
            # OK - Listed applications for virtual host localhost
            # /probe:running:1:probe
            # /manager:running:0:manager
            response_arr = f.read.split(/\n/)
            response_arr.each_with_index do |r, i|
              if i.zero?
                success = r[0, 2] == 'OK'
              elsif r[0, 1] == '/'
                deployed_apps.push(r.split(':')[-1, 1])
              end
            end
          end
          return deployed_apps
        rescue => e
          Chef::Log.error "Error occurred when communicating with Tomcat server: #{e}"
          raise
        end
      end
    end
  end
end
