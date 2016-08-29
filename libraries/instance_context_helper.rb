class Chef::Recipe::ContextHelper

  # Runs every element in the incoming resources array through the
  # normalize function
  def self.normalize_resources(incoming_resources)
    incoming_resources.map { |r| self.normalize_resource(r) }
  end

  def self.normalize_environments(incoming_environments)
    incoming_environments.map { |e| self.normalize_environment(e) }
  end

  # Normalize incoming hash to fill out what a context resource entry should look like
  # http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Resource_Definitions
  def self.normalize_resource(incoming_resource)

    # TODO: I will want to put some sort of validation here
    # if it makes sense. However, I can't depend on this always
    # being a database resource so the logic would have to branch
    # which would increase complexity.

    @default_resource                           = {}

    @default_resource.merge(incoming_resource)
  end

  # Normalize incoming hash to fill out what a context environment entry should look like
  # http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Environment_Entries
  def self.normalize_environment(incoming_environment)
    @default_environment = {
      "name" => "you_did_not_configure_me_correctly",
      "type" => "java.lang.String",
      "value" => "",
      "description" => "",
      "override" => "false"
    }

    @default_environment.merge(incoming_environment)
  end

end
