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
  end
end
