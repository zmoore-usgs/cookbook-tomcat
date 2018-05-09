require 'socket'
require 'timeout'

module Helper
  # Helper functions to get data out of Tomcat attribute definitions
  module TomcatInstance
    def self.instance_exists?(node, instance_name = 'default')
      tomcat_home = node['wsi_tomcat']['user']['home_dir']
      instances_home = ::File.expand_path('instance', tomcat_home)
      instance_home = ::File.expand_path(instance_name, instances_home)
      ::File.exist?(instance_home) && ::File.directory?(instance_home)
    end

    # Returns the ports defined for the instance
    def self.ports(node, instance_name = 'default')
      instance = node['wsi_tomcat']['instances'][instance_name]
      ports = []
      defs = instance['service_definitions']
      defs.each do |x|
        ports.push(x['connector']['port']) unless !x['connector'] || !x['connector']['port']
      end
      ports
    end

    # Returns the tomcat script password if it exists in the encrypted data bag
    def self.script_pass(node, instance_name = 'default')
      instance = node['wsi_tomcat']['instances'][instance_name]

      data_bag_name = instance['context']['encrypted_environments_data_bag']['data_bag_name']
      data_bag_item = instance['context']['encrypted_environments_data_bag']['data_bag_item']

      # I am ignoring FoodCritic F086 here because the Chef resource data_bag_item
      # is not available at this module level
      # http://www.foodcritic.io/#FC086
      # TODO : Figure out how to get data_bag_item available at this level
      Chef::EncryptedDataBagItem.load( # ~FC086
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
      Chef::Log.info 'Checking if Tomcat server is ready'
      begin
        Timeout.timeout(1) do
          sleep 1
          s = TCPSocket.new('127.0.0.1', port)
          s.close
          return true
        end
      rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        check_count += 1
        Chef::Log.info "Tomcat server not yet ready. Check #{check_count} of #{max_attempts}"
        retry if check_count < max_attempts
      end
    end
  end
end
