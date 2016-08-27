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
      node.set[:wsi_tomcat][:data_bag_config][:bag_name] = 'test'
      node.set[:wsi_tomcat][:data_bag_config][:credentials_attribute] = 'credentials'
      node.set[:wsi_tomcat][:user][:home_dir] = "/opt/tomcat"
      node.set[:wsi_tomcat][:user][:name] = "tomcat"
      node.set[:wsi_tomcat][:group][:name] = "tomcat"
      node.set[:wsi_tomcat][:archive][:manager_name] = "manager.tar.gz"
      node.set[:wsi_tomcat][:instances] = {
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

  it 'creates instance home' do
    expect(chef_run).to create_directory('/opt/tomcat/instance/default')
  end


  %w{bin conf lib logs temp webapps work}.each do |dir|
    it "creates directory #{dir} in instance directory" do
      expect(chef_run).to create_directory("/opt/tomcat/instance/default/#{dir}").with(
        owner: "tomcat",
        group: "tomcat"
      )
    end
  end

  [ "catalina.policy",
    "catalina.properties",
    "logging.properties",
    "context.xml",
    "logging.properties",
    "server.xml",
    "tomcat-users.xml",
    "web.xml"
  ].each do |cfg|
    it "templates configuration file #{cfg}" do
      expect(chef_run).to create_template("/opt/tomcat/instance/default/conf/#{cfg}").with(
        owner: "tomcat",
        group: "tomcat",
        sensitive: true
      )
    end
  end

  %w{start stop}.each do |bin_file|
    it "creates template file #{bin_file}" do
      expect(chef_run).to create_template("/opt/tomcat/bin/#{bin_file}_default").with(
        owner: "tomcat",
        group: "tomcat"
      )
    end
  end

  it "creates template file setenv.sh in instance bin path" do
    expect(chef_run).to create_template("/opt/tomcat/instance/default/bin/setenv.sh").with(
      owner: "tomcat",
      group: "tomcat"
    )
  end

  it "creates template file catalinaopts.sh in instance bin path" do
    expect(chef_run).to create_template("/opt/tomcat/instance/default/bin/catalinaopts.sh").with(
      owner: "tomcat",
      group: "tomcat"
    )
  end

  it "creates template file tomcat-initscript.sh.erb in /etc/init.d" do
    expect(chef_run).to create_template("/etc/init.d/tomcat-default").with(
      owner: "root",
      group: "root"
    )
  end

  it "creates manager webapp in instance" do
    allow(File).to receive(:exist?).with('/opt/tomcat/instance/default/webapps/manager').and_return(false)
    expect(chef_run).to run_execute("/bin/tar -xvf /opt/tomcat/archives/manager.tar.gz")
  end

  it "creates tomcat-juli.jar in instance" do
    allow(File).to receive(:exist?).with('/opt/tomcat/instance/default/bin/tomcat-juli.jar').and_return(false)
    expect(chef_run).to run_execute("/bin/cp /opt/tomcat/archives/tomcat-juli.jar /opt/tomcat/instance/default/bin")
  end

  it "runs chkconfig on instance" do
    expect(chef_run).to run_execute("/sbin/chkconfig --level 234 tomcat-default on").with(
      user: "root",
      group: "root"
    )
  end

  it "runs start" do
    expect(chef_run).to run_execute("/bin/bash service tomcat start default").with(
      user: "root",
      group: "root"
    )
  end


end
