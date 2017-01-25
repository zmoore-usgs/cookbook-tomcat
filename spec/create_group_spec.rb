require "spec_helper"

describe "wsi_tomcat::create_group" do
  let (:chef_run) do |runner|
    ChefSpec::SoloRunner.new do |runner|
      runner.node.default[:wsi_tomcat][:group][:name] = "tomcat"
    end.converge(described_recipe)
  end

   it "creates the tomcat group" do
     expect(chef_run).to create_group("tomcat")
   end

end
