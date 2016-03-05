# Name of the group to create for the tomcat user. This probably should remain default
default["wsi_tomcat"]["group"]["name"]    = "tomcat"
default["wsi_tomcat"]["user"]["name"]     = "tomcat"
default["wsi_tomcat"]["user"]["home_dir"] = "/opt/tomcat"

# Set the version of Tomcat to install
default["wsi_tomcat"]["version"]      = "8.0.28"

# Tomcat mirrors. Feel free to add more mirrors as needed. Chef will try to grab from them in order until completed
default["wsi_tomcat"]["file"]["archive"]["mirrors"] = [
  "http://mirror.olnevhost.net/pub/apache/",
  "http://apache.mirrors.lucidnetworks.net/",
  "http://www.webhostingreviewjam.com/mirror/",
  "http://mirror.nexcess.net/apache/",
  "http://archive.apache.org/dist/"
]
# Chef will verify the SHA256 checksum of the downloaded archive
# Generate SHA256 checksum for a file:
# http://www.openoffice.org/download/checksums.html#hash_win
# http://www.openoffice.org/download/checksums.html#hash_linux
# http://www.openoffice.org/download/checksums.html#hash_mac
default["wsi_tomcat"]["file"]["archive"]["checksum"] = "a7a6c092b79fc5a8cffe5916d0e5554254eddcb3c1911ed90696c153b4f13d10"

# Instances definition 
# port = The port that the tomcat instance will run on
# ssl  = Optional. Defines SSL configuration for instance. 
#   ssl.enabled = Defines whether SSL will be used on instance
# user = Defines credentials for various tomcat users
#    See http://tomcat.apache.org/tomcat-7.0-doc/manager-howto.html#Configuring_Manager_Application_Access   
default["wsi_tomcat"]["instances"]["default"]["cors"]["enabled"] = true
default["wsi_tomcat"]["instances"]["default"]["cors"]["allowed"]["origins"] = "*"
default["wsi_tomcat"]["instances"]["default"]["cors"]["allowed"]["methods"] = ["GET", "POST", "HEAD", "OPTIONS"]
default["wsi_tomcat"]["instances"]["default"]["cors"]["allowed"]["headers"] = ["Origin", "Accept", "X-Requested-With", "Content-Type", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
default["wsi_tomcat"]["instances"]["default"]["cors"]["allowed"]["exposed_headers"] = []
default["wsi_tomcat"]["instances"]["default"]["cors"]["allowed"]["preflight_maxage"] = 1800
default["wsi_tomcat"]["instances"]["default"]["cors"]["allowed"]["support_credentials"] = true
default["wsi_tomcat"]["instances"]["default"]["cors"]["allowed"]["filter"] = "/*"
default["wsi_tomcat"]["instances"]["default"]["user"]["disable_admin_users"] = true
default["wsi_tomcat"]["instances"]["default"]["user"]["tomcat_admin_pass"] = "tomcat-admin"
default["wsi_tomcat"]["instances"]["default"]["user"]["tomcat_script_pass"] = "tomcat-script-admin"
default["wsi_tomcat"]["instances"]["default"]["user"]["tomcat_jmx_pass"] = "tomcat-jmx"
default["wsi_tomcat"]["instances"]["default"]["service_definitions"] = [{
  "name" => "Catalina", 
  "thread_pool" => { "max_threads" => 200, "daemon" => "true", "min_spare_threads" => 25, "max_idle_time" => 60000 },
  "connector" => { "port" => 8080 },
  "ssl_connector" => { 
    "enabled" => false, #off by default
    "wsi_tomcat_keys_data_bag" => "name_of_your_data_bag", # see environment/example_keystore_data_bag.json for examples
    "wsi_tomcat_keys_data_item" => "item_in_your_data_bag", # see environment/example_keystore_data_bag.json for examples
    "key_location" => "local_file_path_to_encryption_key", # note: this feature relies on an encryption key being placed on the system before this recipe runs
  },
  "engine" => { "host" => [ "name" => "localhost" ] }
  }]
  
# You can add as many applications as needed by using the following...
# default["wsi_tomcat"]["instances"]["default"]["application"]["app1"] = {
# 	"url" => app1Url,
# 	"final_name" => app1Name
# }
# default["wsi_tomcat"]["instances"]["default"]["application"]["app2"] = {
# 	"url" => app2Url,
# 	"final_name" => app2Name
# }

# if you want to set resource entries in context.xml, notice encrypted attributes entry
# default["wsi_tomcat"]["instances"]["default"]["context"]["resources"] = [
#   { 
#        "description" => "value",
#        "name" => "value",
#        "auth" => "value",
#        "type" => "value",
#        "username" => "value",
#        "password" => "value",
#        "factory" => "value",
#        "driver_class" => "value",
#        "url" => "value",
#        "max_active" => "value",
#        "max_idle" => "value",
#        "remove_abandoned" => "value",
#        "remove_abandoned_timeout" => "value",
#        "log_abandoned" => "value",
#        "test_on_borrow" => "value",
#        "default_auto_commit" => "value",
#        "validation_query" => "value",
#        "access_to_underlying_connection_allowed" => "value",
#        "pool_prepared_statements" => "value",
#        "max_open_prepared_statements" => "value",
#        "encrypted_attributes" => {
#        	"data_bag_name" => "data_bag_to_decrypt",
#        	"key_location" => "location_of_encryption_key",
#        	"field_map" => {
#        		"fromField" : "toField" //EG: take the value from fromField and place it into the toField attribute of the resource
#        	}
#        }
#}]


# if you want to set environment variable entries in context.xml
# default["wsi_tomcat"]["instances"]["default"]["context"]["environments"] = [
#   { "name" => "propName", "type" => "java.lang.String", "override" => true, "value" => "propValue"}]


# To pull a list (extract_fields) from an encrypted data_bag and add them to the context.xml as String properties.
# this feature relies on an encryption key being placed on the system before this recipe runs
# default["wsi_tomcat"]["instances"]["default"]["context"]["encrypted_environments_data_bag"] = {
#   "data_bag_name" => "name_of_your_data_bag",
#   "data_bag_item" => "name_of_item_in_data_bag",
#   "key_location" => "local_file_path_to_encryption_key",
#   "extract_fields" => ["field1", "field2", "field3"]
# }

default["wsi_tomcat"]["disable_manager"] = false
default["wsi_tomcat"]["archive"]["manager_name"] = "manager_war.tar.gz"

# you can download libs into the main lib director by providing a list of URLs and the final file name to create
# eg: default["wsi_tomcat"]["lib_sources"] = [{ filename: "mylib.jar", url: "http://www.website.com/mylib.jar" }]
default["wsi_tomcat"]["lib_sources"] = []

# JAVA Installation Options
# https://supermarket.chef.io/cookbooks/java
default["java"]["install_flavor"] = "oracle"
default["java"]["oracle"]["accept_oracle_download_terms"] = true
default["java"]["jdk_version"] = "8"
default["java"]["set_etc_environment"] = true
