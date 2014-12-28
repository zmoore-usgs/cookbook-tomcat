require "spec_helper"

describe "wsi_tomcat::commons_daemon" do
   let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
   
   before do
     stub_command("test -n \"$(ls -A /opt/commons_daemon)\"").and_return(false)
   end
   
   tomcat_home = "/opt/tomcat"
   unpack_directory = "/opt/commons_daemon"
   work_directory = "#{unpack_directory}/unix"
   
   it "creates the /opt/commons_daemon directory" do
     expect(chef_run).to create_directory("/opt/commons_daemon").with(
     owner: "tomcat",
     group: "tomcat"
     )
   end
   
   it "unpacks the commons daemon archive" do
     expect(chef_run).to run_execute("/bin/tar xvf /opt/tomcat/bin/commons-daemon-native.tar.gz --strip=1 -C /opt/commons_daemon")
   end
   
   it "runs configure on BCDP source" do
     expect(chef_run).to run_execute("./configure")
   end
   
   it "runs make on BCDP source to make jsvc binary" do
      expect(chef_run).to run_execute("make")
   end
   
   it "copies BCDP executable to tomcat's bin directory" do
     expect(chef_run).to run_execute("/bin/cp #{work_directory}/jsvc  #{tomcat_home}/bin")
   end

end