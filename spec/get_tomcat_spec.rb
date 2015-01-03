require "spec_helper"

describe "wsi_tomcat::get_tomcat" do
   let (:chef_run) do |runner|
     ChefSpec::SoloRunner.new do |runner| 
       runner.node.set[:wsi_tomcat][:version] = '7.0.57'
       runner.node.set[:wsi_tomcat][:group][:name] = 'tomcat'
       runner.node.set[:wsi_tomcat][:user][:name] = 'tomcat'
     end.converge(described_recipe)
   end
   
   unpack_dir = "/opt/apache-tomcat-7.0.57"
   
   it "get remote tomcat binary" do
     expect(chef_run).to create_remote_file_if_missing("/opt/apache-tomcat-7.0.57.tar.gz").with(
       owner: 'tomcat'
     )
   end
   
   it "unpacks the tomcat binary" do
     expect(chef_run).to_not run_execute("unpack tomcat binary").with(
       cwd: "/opt",
       creates: unpack_dir
     )
   end
   
   it "gain rights for base dir" do
     expect(chef_run).to_not run_execute("gain rights for base dir").with(
       user: 'root'
     )
   end
   
   it "links /opt/tomcat to the unpack directory" do
     expect(chef_run).to create_link("/opt/tomcat").with(
     owner: "tomcat",
     group: "tomcat",
     to: "/opt/apache-tomcat-7.0.57"
     )
   end

end
