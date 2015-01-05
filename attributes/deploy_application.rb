# These attributes are used in the example cookbook for deploying applications
default[:wsi_tomcat][:instances][:default][:application][:psiprobe][:url]                 = 'http://cida.usgs.gov/maven/cida-public-thirdparty/com/googlecode/psiprobe/web/2.3.3/web-2.3.3.war'
default[:wsi_tomcat][:instances][:default][:application][:psiprobe][:final_name]          = 'psi-probe'