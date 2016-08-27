# Name of the group to create for the tomcat user. This probably should remain default
default["wsi_tomcat"]["group"]["name"]    = "tomcat"
default["wsi_tomcat"]["user"]["name"]     = "tomcat"
default["wsi_tomcat"]["user"]["home_dir"] = "/opt/tomcat"

# If an instance is not listed in the Chef configuration but appears running on
# the system, should the instance be removed?
default["wsi_tomcat"]["deploy"]["remove_unlisted_instances"] = true
# If an application is not listed in the Chef configuration but appears running on
# the system, should the application be removed?
default["wsi_tomcat"]["deploy"]["remove_unlisted_applications"] = true

# Set the version of Tomcat to install
default["wsi_tomcat"]["version"]      = "8.0.36"

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

# MacOS example:
# openssl dgst -sha256 apache-tomcat-8.0.36.tar.gz
# SHA256(apache-tomcat-8.0.36.tar.gz)= 7963464d86faf8416b92fb2b04c70da9759c7c332e1700c1e9f581883b4db664
default["wsi_tomcat"]["file"]["archive"]["checksum"] = "7963464d86faf8416b92fb2b04c70da9759c7c332e1700c1e9f581883b4db664"

# Some credentials are stored in an encrypted data bag
default["wsi_tomcat"]['data_bag_config']['bag_name'] = "wsi_tomcat-_default"
# This stores Tomcat passwords for things like the Tomcat manager application
# Example can be found in test/integration/default/credentials_unencrypted.json
# Each tomcat instance should have its own top-level credentials object
# {
#   "id" : "credentials",
#   "default" : {
#     "tomcat_admin_pass" : "tomcat-admin",
#     "tomcat_script_pass" : "tomcat-script-admin",
#     "tomcat_jmx_pass" : "tomcat-jmx"
#   }
# }
default["wsi_tomcat"]['data_bag_config']['credentials_attribute'] = "credentials"


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
default["wsi_tomcat"]["instances"]["default"]["user"]["disable_admin_users"] = false

# https://tomcat.apache.org/tomcat-8.0-doc/config/context.html
default["wsi_tomcat"]["instances"]["default"]["context"]["attributes"]["anti_jar_locking"] = true
default["wsi_tomcat"]["instances"]["default"]["context"]["attributes"]["anti_resource_locking"] = true
default["wsi_tomcat"]["instances"]["default"]["context"]["attributes"]["allow_casual_multipart_parsing"] = false
default["wsi_tomcat"]["instances"]["default"]["context"]["attributes"]["background_processor_delay"] = "-1"
default["wsi_tomcat"]["instances"]["default"]["context"]["attributes"]["container_sci_filter"] = ""

# TODO
# default["wsi_tomcat"]["instances"]["default"]["context"]["class_name"] = ""

default["wsi_tomcat"]["instances"]["default"]["service_definitions"] = [{
                                                                          "name" => "Catalina",
                                                                          "thread_pool" => { "max_threads" => 200, "daemon" => "true", "min_spare_threads" => 25, "max_idle_time" => 60000 },
                                                                          "connector" => { "port" => 8080 },
                                                                          "ssl_connector" => {
                                                                            "enabled" => false,
                                                                            "wsi_tomcat_keys_data_bag" => "wsi_tomcat-_default", # see test/integration/default/keystore_unencrypted.json for examples
                                                                            "wsi_tomcat_keys_data_item" => "keystores", # see environment/example_keystore_data_bag.json for examples

                                                                            # If you already have a certificate file:
                                                                            "ssl_cert_file" => "", # file:///path/to/remote/crt/file/if/available.crt
                                                                            "ssl_key_file" => "", # file:///path/to/remote/key/file/if/available.key

                                                                            # If you have certificates per host...
                                                                            # [ {"name" : "www.host1.com" , "path" : "file:///path/to/trustcert1/crt"}, {"name" : "www.host2.com" , "path" : "file:///path/to/trustcert2/crt"}]
                                                                            # or to create self-signed certs per host...
                                                                            # [ {"name" : "www.host1.com"}, {"name" : "www.host2.com"}]
                                                                            "trust_certs" => [],

                                                                            # If you want this cookbook to create certs:
                                                                            "directory_info" => {
                                                                              "name" => "gov.usgs.cida",
                                                                              "org_unit" => "DevOps",
                                                                              "org" => "CIDA",
                                                                              "locality" => "Middleton",
                                                                              "state" => "WI",
                                                                              "country" => "US"
                                                                            },

                                                                          },
                                                                          "engine" => { "host" => [ "name" => "localhost" ] }
}]

# You can add as many applications as needed by using the following...
# default["wsi_tomcat"]["instances"]["default"]["application"]["app1"] = {
#   "url" => app1Url,
#   "final_name" => app1Name
# }
# default["wsi_tomcat"]["instances"]["default"]["application"]["app2"] = {
#   "url" => app2Url,
#   "final_name" => app2Name
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
#        "remove_abandoned_on_borrow" => "value",
#        "remove_abandoned_timeout" => "value",
#        "log_abandoned" => "value",
#        "test_on_borrow" => "value",
#        "default_auto_commit" => "value",
#        "validation_query" => "value",
#        "access_to_underlying_connection_allowed" => "value",
#        "pool_prepared_statements" => "value",
#        "max_open_prepared_statements" => "value",
#        "encrypted_attributes" => {
#         "data_bag_name" => "data_bag_to_decrypt",
#         "field_map" => {
#           "fromField" : "toField" //EG: take the value from fromField and place it into the toField attribute of the resource
#         }
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
#   "extract_fields" => ["field1", "field2", "field3"]
# }
default["wsi_tomcat"]["disable_manager"] = false

default["wsi_tomcat"]["archive"]["manager_name"] = "manager_war.tar.gz"

# you can download libs into the main lib director by providing a list of URLs and the final file name to create
# eg: default["wsi_tomcat"]["lib_sources"] = [{ filename: "mylib.jar", url: "http://www.website.com/mylib.jar" }]
default["wsi_tomcat"]["lib_sources"] = []
