#
# Cookbook Name:: wsi_tomcat
# Recipe:: update_context
# Author: Ivan Suftin < isuftin@usgs.gov >
#
# Description: Updates context.xml

instances    = node['wsi_tomcat']['instances']
tomcat_group = node['wsi_tomcat']['group']['name']
tomcat_user  = node['wsi_tomcat']['user']['name']
tomcat_home  = node['wsi_tomcat']['user']['home_dir']
context_xml  = 'context.xml'
r            = []
e            = []

instances.each do |instance, attributes|
  conf_path = "#{tomcat_home}/instance/#{instance}/conf/#{context_xml}"

  if attributes.key?('context')

    Chef::Log.info("Updating #{instance} context")

    anti_jar_locking = attributes['context'].fetch(:anti_jar_locking, true)
    anti_resource_locking = attributes['context'].fetch(:anti_resource_locking, true)
    allow_casual_multipart_parsing = attributes['context'].fetch(:allow_casual_multipart_parsing, false)
    background_processor_delay = attributes['context'].fetch(:background_processor_delay, '-1')
    original_resources    = attributes['context'].fetch(:resources, [])
    original_environments = attributes['context'].fetch(:environments, [])

    unless original_resources.empty?
      r.push(ContextHelper.normalize_resources(original_resources))
    end

    # decrypt resource attributes
    r.each do |r1|
      r1.each do |res|
        next unless res.key?('encrypted_attributes')
        encrypted_attributes = res['encrypted_attributes']
        data_bag_name = encrypted_attributes['data_bag_name']
        data_bag_item = encrypted_attributes['data_bag_item']
        field_map = encrypted_attributes['field_map']
        data_bag = data_bag_item(data_bag_name, data_bag_item)

        # I don't want this value to come through to the
        # actual context file. I got what I need from this
        # variable, so delete it from the hash
        res.delete('encrypted_attributes')

        field_map.each do |k, v|
          res[v] = data_bag[k]
        end
      end
    end

    unless original_environments.empty?
      e.push(ContextHelper.normalize_environments(original_environments))
    end

    # encrypted properties to be used as String kvps
    if attributes['context'].key?('encrypted_environments_data_bag')
      enc_environments_data_bag = attributes['context'].fetch(:encrypted_environments_data_bag, {})
      data_bag_name = enc_environments_data_bag['data_bag_name']
      data_bag_item = enc_environments_data_bag['data_bag_item']
      extract_fields = enc_environments_data_bag['extract_fields']

      data_bag = data_bag_item(data_bag_name, data_bag_item)
      extract_fields.each do |prop_name|
        e.push(
          'name' => prop_name,
          'value' => data_bag[prop_name],
          'type' => 'java.lang.String',
          'override' => true
        )
      end
    end
  end

  # Restart if context changed
  tomcat_instance instance do
    action :nothing
  end

  template conf_path do
    owner tomcat_user
    group tomcat_group
    source "instances/conf/#{context_xml}.erb"
    sensitive true
    variables(
      version: node['wsi_tomcat']['version'],
      anti_jar_locking: anti_jar_locking,
      anti_resource_locking: anti_resource_locking,
      allow_casual_multipart_parsing: allow_casual_multipart_parsing,
      background_processor_delay: background_processor_delay,
      resources: r.flatten,
      environments: e.flatten
    )
    notifies :restart, "tomcat_instance[#{instance}]", :immediate
  end
end
