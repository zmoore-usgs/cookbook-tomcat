require "spec_helper"

describe "wsi_tomcat::install_deps" do
  let (:chef_run) do |runner|
    ChefSpec::SoloRunner.new do |runner|
    end.converge(described_recipe)
  end

  ENV['JAVA_HOME'] = ''

  it "installs gcc" do
    expect(chef_run).to install_package('gcc')
  end

end
