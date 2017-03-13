name             'wsi_tomcat'
maintainer       'Ivan Suftin'
maintainer_email 'isuftin@usgs.gov'
license          'Public Domain'
description      'Installs and configures the Apache Tomcat servlet container '
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          '1.0.1'
supports         'centos', '>= 6.5'

depends 'java'

source_url 'https://github.com/USGS-CIDA/cookbook-tomcat'
issues_url 'https://github.com/USGS-CIDA/cookbook-tomcat/issues'
