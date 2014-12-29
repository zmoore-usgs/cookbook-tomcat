require "spec_helper"

describe "wsi_tomcat::create_tomcat_base" do
   let (:chef_run) do |runner|
     ChefSpec::SoloRunner.new do |runner|
       runner.node.set[:wsi_tomcat][:file][:base_dir][:include] =['one']
       runner.node.set[:wsi_tomcat][:user][:home_dir] = "/opt/tomcat"
     end.converge(described_recipe)
   end
   
     it "get remote tomcat binary" do
        expect(chef_run).to create_directory("/opt/tomcat/one").with(
          owner: 'tomcat',
          group: 'tomcat'
        )
    end
  
 end