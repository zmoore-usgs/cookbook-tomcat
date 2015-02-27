# Name of the group to create for the tomcat user. This probably should remain default
default["wsi_tomcat"]["group"]["name"]    = "tomcat"
default["wsi_tomcat"]["user"]["name"]     = "tomcat"
default["wsi_tomcat"]["user"]["home_dir"] = "/opt/tomcat"


# Set the version of Tomcat to install
default["wsi_tomcat"]["version"]      = "7.0.57"
default["wsi_tomcat"]["version_base"] = default["wsi_tomcat"]["version"] .split(".")[0]

# Tomcat mirrors. Feel free to add more mirrors as needed. Chef will try to grab from them in order until completed
tomcat_url_fragment                   = "tomcat/tomcat-#{wsi_tomcat.version_base}/v#{wsi_tomcat.version}/bin/apache-tomcat-#{wsi_tomcat.version}.tar.gz"
default["wsi_tomcat"]["file"]["archive"]["mirrors"] = [
  "http://archive.apache.org/dist/#{tomcat_url_fragment}"
]
# Chef will verify the SHA256 checksum of the downloaded archive
# Generate SHA256 checksum for a file:
# http://www.openoffice.org/download/checksums.html#hash_win
# http://www.openoffice.org/download/checksums.html#hash_linux
# http://www.openoffice.org/download/checksums.html#hash_mac
default["wsi_tomcat"]["file"]["archive"]["checksum"] = "1ce390049ed23143e3db0c94781c1e88a4d1b39ceb471c0af088a0c326d637cb"

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
default["wsi_tomcat"]["instances"]["default"]["user"]["tomcat_admin_pass"] = "tomcat-admin"
default["wsi_tomcat"]["instances"]["default"]["user"]["tomcat_script_pass"] = "tomcat-script-admin"
default["wsi_tomcat"]["instances"]["default"]["user"]["tomcat_script_pass"] = "tomcat-script-admin"
default["wsi_tomcat"]["instances"]["default"]["user"]["tomcat_jmx_pass"] = "tomcat-jmx"
default["wsi_tomcat"]["instances"]["default"]["service_definitions"] = [{
  "name" => "Catalina", 
  "thread_pool" => { "max_threads" => 200, "daemon" => "true", "min_spare_threads" => 25, "max_idle_time" => 60000 },
  "connector" => { "port" => 8080 },
  "ssl_connector" => { "enabled" => true},
  "engine" => { "host" => [ "name" => "localhost" ] }
  }]

default["wsi_tomcat"]["archive"]["manager_name"] = "manager_war.tar.gz"

# JAVA Installation Options
# https://supermarket.chef.io/cookbooks/java
default["java"]["jdk_version"] = "7"
default["java"]["set_etc_environment"] = true
