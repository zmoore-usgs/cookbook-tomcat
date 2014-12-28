require "spec_helper"

describe "wsi_tomcat::get_tomcat" do
   #let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
   let (:chef_run) do |runner|
     ChefSpec::SoloRunner.new do |runner| 
       runner.node.set['wsi_tomcat']['version'] = '7.0.57'
     end.converge(described_recipe)
     
   end
   
   
   it "get remote tomcat binary" do
     expect(chef_run).to create_remote_file_if_missing("/opt/apache-tomcat-7.0.57.tar.gz").with(
       owner: 'tomcat'
     )
   end

   
end