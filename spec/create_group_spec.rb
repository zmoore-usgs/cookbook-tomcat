require "spec_helper"

describe "wsi_tomcat::create_group" do
   let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
   
   it "creates the tomcat group" do
     expect(chef_run).to create_group("tomcat")
   end
   
end
