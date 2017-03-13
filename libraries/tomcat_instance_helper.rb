require 'socket'
require 'timeout'

module Helper
  # Helper functions to get data out of Tomcat attribute definitions
  module TomcatInstance
    # Returns the ports defined for the instance
    def self.ports(node, instance_name = 'default')
      instance = node['wsi_tomcat']['instances'][instance_name]
      ports = []
      defs = instance['service_definitions']
      defs.each do |x|
        ports.push(x['connector']['port']) unless !x.connector || !x.connector.port
      end
      ports
    end

    # Returns the tomcat script password if it exists in the encrypted data bag
    def self.script_pass(node, instance_name = 'default')
      instance = node['wsi_tomcat']['instances'][instance_name]

      data_bag_name = instance['context']['encrypted_environments_data_bag']['data_bag_name']
      data_bag_item = instance['context']['encrypted_environments_data_bag']['data_bag_item']

      Chef::EncryptedDataBagItem.load(
        data_bag_name,
        data_bag_item
      )[instance_name]['tomcat_script_pass']
    end

    # Checks if a Tomcat instance is ready by attempting to connect at the
    # instance's port. Will check every 1 second for a specified number of
    # iterations denoted by the max_attempts attribute (default: 60)
    def self.ready?(node, instance_name = 'default', max_attempts = 60)
      port = ports(node, instance_name)[0]

      check_count = 0
      Chef::Log.info "Checking if Tomcat server is ready"
      begin
        Timeout.timeout(1) do
          # begin
            sleep 1
            s = TCPSocket.new('127.0.0.1', port)
            s.close
            return true
          # rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          #   check_count += 1
          #   Chef::Log.info "Tomcat server not yet ready. Check #{check_count} of #{max_attempts}"
          #   retry if check_count < max_attempts
          # end
        end
      rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        check_count += 1
        Chef::Log.info "Tomcat server not yet ready. Check #{check_count} of #{max_attempts}"
        retry if check_count < max_attempts
      end
    end
  end
end
