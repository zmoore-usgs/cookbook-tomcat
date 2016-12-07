Tomcat Cookbook Changelog
=========

0.2.2
------
- [isuftin@usgs.gov] - Quick fix for SSL configuration breaking

0.2.1
------
- [isuftin@usgs.gov] - Fixing APR implementation.
- [isuftin@usgs.gov] - Adding ability to add options to setenv
- [isuftin@usgs.gov] - Fleshing out server.xml options
- [isuftin@usgs.gov] - Fixing a breaking bug when some attributes were not included in server definitions 

0.2.0
------
- [isuftin@usgs.gov] - Major switch to how context.xml resource parameters are set. Allowing cookbooks to pass parameters directly instead of translating. This saves me having to deal with what is probably useless maintenance. 
- [isuftin@usgs.gov] - Added database testing to Kitchen suite
- [isuftin@usgs.gov] - Moved Java cookbook dependency version to Berksfile
- [isuftin@usgs.gov] - Set JAVA_HOME in .bashrc
- [isuftin@usgs.gov] - Fix how JAVA_HOME gets persisted to Tomcat scripts
- [isuftin@usgs.gov] - Adding more context.xml attributes 
- [isuftin@usgs.gov] - Added APR installation recipe

0.1.13
------
- [isuftin@usgs.gov] - Moved java installation out of dependencies cookbook. Should be done
	at a higher level outside of this cookbook
- [isuftin@usgs.gov] - Added DOI SSL helper cookbook to Berksfile. Only needs to exist in tests when
	testing on DOI network

0.1.12
------
- [isuftin@usgs.gov] - Updated to version 8.0.36 default for Tomcat. 
- [isuftin@usgs.gov] - Added some documentation for getting SHA256 for binary

0.1.12
------
- [isuftin@usgs.gov] - Updated to version 8.0.36 default for Tomcat. 
- [isuftin@usgs.gov] - Added some documentation for getting SHA256 for binary

0.1.11
------
- [isuftin@usgs.gov] - Parameterized more context.xml templating
- [isuftin@usgs.gov] - Updated CORS attribute parsing (Ruby hash entity vs string keys)

0.1.10
------
- [isuftin@usgs.gov] - Added Tomcat resource action to undeploy an application
- [isuftin@usgs.gov] - Added Tomcat resource action to remove instances not in configuration

0.1.9
-----
- [isuftin@usgs.gov] - Added sensitivity to templates
- [isuftin@usgs.gov] - Fixed server opts updating
- [isuftin@usgs.gov] - Removed the `application_name` attribute
- [isuftin@usgs.gov] - Updated how encrypted data bags are accessed
- [isuftin@usgs.gov] - Added more attributes to put into context.xml and server.xml

0.1.8
-----
- Removed requirement for specifying key location. Using default key location as according to Chef
- No longer taking certificates baked into encrypted data bag. Certificates are now either created on the fly or provided on the file system

0.1.7
-----
- Updated default Tomcat version to install
- Added more CentOS options to Test Kitchen
- Updated Test Kitchen CentOS boxes to use mainly Bento box versions
- Added STIG testing option to Test Kitchen
- Moved default Java installation options to be defined outside of attributes (like in Test Kitchen)
- Moved some passwords into an encrypted data bag (and included documentation)
- Added more Serverspec testing