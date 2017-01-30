require "spec_helper"

describe "wsi_tomcat::create_tomcat_instances" do
  let(:chef_run) do
    ChefSpec::ServerRunner.new do |node, server|
      server.create_data_bag('test', {

                               'id' => 'credentials',
                               'default' => {
                                 'tomcat_admin_pass' => 'tomcat-admin',
                                 'tomcat_script_pass' => 'tomcat-script-admin',
                                 'tomcat_jmx_pass' => 'tomcat-jmx'
                               },
                               'test' => {
                                 'tomcat_admin_pass' => 'tomcat-admin',
                                 'tomcat_script_pass' => 'tomcat-script-admin',
                                 'tomcat_jmx_pass' => 'tomcat-jmx'
                               }

      })
      node.default[:wsi_tomcat][:data_bag_config][:bag_name] = 'test'
      node.default[:wsi_tomcat][:data_bag_config][:credentials_attribute] = 'credentials'
      node.default[:wsi_tomcat][:user][:home_dir] = "/opt/tomcat"
      node.default[:wsi_tomcat][:user][:name] = "tomcat"
      node.default[:wsi_tomcat][:group][:name] = "tomcat"
      node.default[:wsi_tomcat][:archive][:manager_name] = "manager.tar.gz"
      node.default[:wsi_tomcat][:instances] = {
        :default => {
          :port => 8080,
          :ssl  => {
            :enabled => true
          },
          :server_opts => [ "server" ],
          :cors => {
            :enabled => true,
            :allowed => {
              :origins => "*",
              :methods => ["GET", "POST", "HEAD", "OPTIONS"],
              :headers => ["Origin", "Accept", "X-Requested-With", "Content-Type", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
            },
            :exposed_headers => [],
            :preflight_maxage => 1800,
            :support_credentials => true,
            :filter => "/*"
          },
          :user => {
            :tomcat_admin_pass => "tomcat-admin",
            :tomcat_script_pass => "tomcat-script",
            :tomcat_jmx_pass => "tomcat-jmx"
          }
        }
      }
    end.converge(described_recipe)
  end

  before(:each) do
    stub_command("chkconfig | grep -q 'tomcat-default'").and_return(false)
    stub_search("wsi_tomcat-_default", "id:credentials").and_return(false)
  end

  before do
    # https://github.com/sethvargo/chefspec/issues/250
    allow(File).to receive(:exist?).and_call_original
  end

  it 'runs wsi_tomcat_instance(:create)' do
    expect(chef_run).to create_instance('default')
  end

end
