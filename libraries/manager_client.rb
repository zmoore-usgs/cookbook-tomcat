require 'open-uri'

module Helper
  # Cookbook Name:: wsi_tomcat
  # Module:: Helper::ManagerClient
  # @author Ivan Suftin < isuftin@usgs.gov >
  # @since 1.0.0
  #
  # Description: Helper functions to communicate with the Tomcat manager application
  module ManagerClient
    # Communicates with the running Tomcat container at a given port and returns
    # an array of application names currently deployed on the server. If a
    # communication error occurs, an exception is thrown.
    # @param port [String] Defines the port that the target Tomcat server is listening on, `8080`
    # @param tomcat_script_pass [String] Provides the password used with the manager
    #   application. This password is for the tomcat-script user, `fuh438hr73`
    # @return [String] The server response,
    #   `OK - Listed applications for virtual host localhost
    #   `/webdav:running:0:webdav`
    #   `/examples:running:0:examples`
    #   `/manager:running:0:manager`
    #   `/:running:0:ROOT`
    #   `/test:running:0:test##2`
    #   `/test:running:0:test##1`
    # @raise [Error] If the server responds with an error
    # @note This method is a helper method for other methods. A recipe would
    #   probably not need to use this directly
    # @since 1.0.0
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
              deployed_apps.push(r.split(':'))
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
    #
    # @param port [String] Defines the port that the target Tomcat server is listening on, `8080`
    # @param tomcat_script_pass [String] Provides the password used with the manager
    #   application. This password is for the tomcat-script user, `fuh438hr73`
    # @param application_path [String] The context path the application should be undeployed from,`/probe`
    # @param aplication_version [String] Optional. The version of the application, `1.0.3M4`
    # @return [String] The server response, `OK - Undeployed application at context path /examples`
    # @raise [Error] If the server responds with an error
    # @since 1.0.0
    def self.undeploy_application(port, tomcat_script_pass, application_path, *application_version)
      undeploy_command = '/manager/text/undeploy'
      undeploy_command << "?path=#{application_path}"
      undeploy_command << "&version=#{application_version}" unless application_version.to_s.strip.empty?
      open(
        "http://127.0.0.1:#{port}#{undeploy_command}",
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

    # Deploys a Tomcat application from a war, xml or directory
    #
    # @param port [String] Defines the port that the target Tomcat server is listening on, `8080`
    # @param tomcat_script_pass [String] Provides the password used with the manager
    #   application. This password is for the tomcat-script user, `fuh438hr73`
    # @param aplication_version [String] Optional. The version of the application.
    #   This provides the ability to do parallel deployment.
    #   See: https://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Parallel_deployment, `1.0.3M4`
    # @param application_location [String] Points to the location of the deployable
    #   artifact that is on the same file system as the Tomcat server, `file:/tmp/deployable.war`
    # @param application_path [String] The context path the application should be launched into,`/probe`
    # @return [String] The server response, `OK - Deployed application at context path /foo`
    # @raise [Error] If the server responds with an error
    # @since 1.0.0
    def self.deploy_application(port, tomcat_script_pass, application_version, application_location, application_path, tag = '')
      deploy_command = '/manager/text/deploy'
      deploy_command << "?path=#{application_path}"
      deploy_command << "&war=file:#{application_location}"
      deploy_command << "&version=#{application_version}" unless application_version.to_s.strip.empty?
      deploy_command << '&update=true'
      deploy_command << "&tag=#{tag}" unless tag.to_s.strip.empty?

      open(
        "http://127.0.0.1:#{port}#{deploy_command}",
        http_basic_authentication: ['tomcat-script', tomcat_script_pass.to_s]
      ) do |f|
        # First result will be the response for this command
        response = f.read
        status = response.split(' ')[0]
        raise response unless status == 'OK'
        Chef::Log.info "Deplopyed new application to #{application_path}"
        return response
      end
    rescue => e
      Chef::Log.error "Error occurred when communicating with Tomcat server: #{e}"
      raise
    end
  end
end
