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
  # http://tomcat.apache.org/tomcat-7.0-doc/config/context.html#Resource_Definitions 
  def self.normalize_resource(incoming_resource)
    @default_resource                           = {
      "name"                                    => "jdbc/insert_name_here",
      "auth"                                    => "Container",
      "type"                                    => "javax.sql.DataSource",
      "username"                                => "",
      "password"                                => "",
      "factory"                                 => "org.apache.commons.dbcp.BasicDataSourceFactory",
      "driver_class"                            => "oracle.jdbc.OracleDriver",
      "url"                                     => "jdbc:oracle:thin:@some.db.address.usgs.gov:1521:db",
      "max_active"                              => "10",
      "max_idle"                                => "10",
      "remove_abandoned"                        => "true",
      "remove_abandoned_timeout"                => "true",
      "log_abandoned"                           => "true",
      "test_on_borrow"                          => "true",
      "default_auto_commit"                     => "false",
      "validation_query"                        => "SELECT 1 FROM DUAL",
      "access_to_underlying_connection_allowed" => "true",
      "pool_prepared_statements"                => "true",
      "max_open_prepared_statements"            => "400"
    }
    
    @default_resource.merge(incoming_resource)
  end
  
  # Normalize incoming hash to fill out what a context environment entry should look like
  # http://tomcat.apache.org/tomcat-7.0-doc/config/context.html#Environment_Entries
  def self.normalize_environment(incoming_environment)
    @default_environment = {
      "name" => "insert_name_here",
      "type" => "java.lang.String",
      "value" => "",
      "description" => "",
      "override" => "false"
    }
    @default_environment.merge(incoming_environment)
  end
  
end
