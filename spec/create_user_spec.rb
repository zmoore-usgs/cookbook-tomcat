require "spec_helper"

describe "wsi_tomcat::create_user" do
   let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
   
   it "creates the tomcat user" do
     expect(chef_run).to create_user("tomcat").with(
       system: true,
       group: 'tomcat',
       home: '/opt/tomcat',
       gid: 'tomcat'
     )
   end
   
end
