require "spec_helper"

describe "wsi_tomcat::create_tomcat_base" do
   let (:chef_run) do |runner|
     ChefSpec::SoloRunner.new do |runner|
       runner.node.set[:wsi_tomcat][:user][:home_dir] = "/opt/tomcat"
       runner.node.set[:wsi_tomcat][:user][:name] = "tomcat"
       runner.node.set[:wsi_tomcat][:group][:name] = "tomcat"
       runner.node.set[:wsi_tomcat][:archive][:manager_name] = "some-archive.tar.gz"
     end.converge(described_recipe)
   end

   it "creates home directories" do
     [
       "instance",
       "heapdumps",
       "data",
       "run",
       "share",
       "ssl",
       "ssltmp",
       "archives"
     ].each do |dir|
       expect(chef_run).to create_directory("/opt/tomcat/#{dir}")
     end 
   end

   it "archive manager webapp" do
     expect(chef_run).to run_execute("/bin/tar -czvf /opt/tomcat/archives/some-archive.tar.gz manager").with(
     user: "tomcat",
     group: "tomcat",
     cwd:  "/opt/tomcat/webapps"
     )
   end
   
   it "archive juli webapp" do
     expect(chef_run).to run_execute("/bin/cp tomcat-juli.jar /opt/tomcat/archives").with(
     user: "tomcat",
     group: "tomcat",
     cwd:  "/opt/tomcat/bin"
     )
   end
   
   it "deletes directories from home" do
     [
       "temp",
       "work",
       "webapps"
     ].each do |dir|
       expect(chef_run).to delete_directory("/opt/tomcat/#{dir}")
     end
   end
   
   it "deletes files from bin" do
     [
       "shutdown.bat",
       "version.bat",
       "digest.bat",
       "tool-wrapper.bat",
       "startup.bat",
       "catalina.bat",
       "setclasspath.bat",
       "configtest.bat"
     ].each do |file|
       expect(chef_run).to delete_file("/opt/tomcat/bin/#{file}")
     end
   end
   
   it "deletes files from home" do
     [
       "LICENSE",
       "NOTICE",
       "RELEASE-NOTES",
       "RUNNING.txt"
     ]
     .each do |file|
       expect(chef_run).to delete_file("/opt/tomcat/#{file}")
     end
   end
   
   it "templates the tomcat bin file" do
     expect(chef_run).to create_template("/opt/tomcat/bin/tomcat").with(
     owner: "tomcat",
     group: "tomcat",
     source: "bin/tomcat.erb"
     )
   end
   
   it "templates tomcat init script" do
     expect(chef_run).to create_template("/etc/init.d/tomcat").with(
     owner: "root",
     group: "root",
     source: "tomcat-initscript.sh.erb"
     )
   end
   
   it "templates bash_profile script" do
     expect(chef_run).to create_template("/opt/tomcat/.bash_profile").with(
     owner: "tomcat",
     group: "tomcat",
     source: ".bash_profile.erb"
     )
   end
   
   it "templates bashrc script" do
     expect(chef_run).to create_template("/opt/tomcat/.bashrc").with(
     owner: "tomcat",
     group: "tomcat",
     source: ".bashrc.erb"
     )
   end
  
 end