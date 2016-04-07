# wsi_tomcat

Installs Tomcat, see attributes/default.rb for configuration options

#### Changelog

-- v0.1.7
- Updated default Tomcat version to install
- Added more CentOS options to Test Kitchen
- Updated Test Kitchen CentOS boxes to use mainly Bento box versions
- Added STIG testing option to Test Kitchen
- Moved default Java installation options to be defined outside of attributes (like in Test Kitchen)
- Moved some passwords into an encrypted data bag (and included documentation)
- Added more Serverspec testing