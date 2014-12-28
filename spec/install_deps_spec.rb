require "spec_helper"

describe "wsi_tomcat::install_deps" do
   let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

   it "includes java cookbook" do
     expect(chef_run).to include_recipe('java')
   end

   it "installs gcc" do
     expect(chef_run).to install_package('gcc')
   end

end