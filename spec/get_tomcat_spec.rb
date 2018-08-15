require "spec_helper"
tc_version = '8.5.32'
describe "wsi_tomcat::get_tomcat" do
   let (:chef_run) do |_runner|
     ChefSpec::SoloRunner.new do |runner|
       runner.node.default[:wsi_tomcat][:version] = tc_version
       runner.node.default[:wsi_tomcat][:group][:name] = 'tomcat'
       runner.node.default[:wsi_tomcat][:user][:name] = 'tomcat'
     end.converge(described_recipe)
   end

   unpack_dir = "/opt/apache-tomcat-#{tc_version}"

   it "get remote tomcat binary" do
     expect(chef_run).to create_remote_file_if_missing("/opt/apache-tomcat-#{tc_version}.tar.gz").with(
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
     to: "/opt/apache-tomcat-#{tc_version}"
     )
   end

end
