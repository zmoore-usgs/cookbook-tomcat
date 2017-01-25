require "spec_helper"

describe "wsi_tomcat::create_user" do
  let (:chef_run) do |runner|
    ChefSpec::SoloRunner.new do |runner|
      runner.node.default[:wsi_tomcat][:user][:name] = "tomcat"
      runner.node.default[:wsi_tomcat][:group][:name] = "tomcat"
      runner.node.default[:wsi_tomcat][:user][:home_dir] = "/opt/tomcat"
    end.converge(described_recipe)
  end

   it "creates the tomcat user" do
     expect(chef_run).to create_user("tomcat").with(
       system: true,
       group: 'tomcat',
       home: '/opt/tomcat',
       gid: 'tomcat'
     )
   end

end
