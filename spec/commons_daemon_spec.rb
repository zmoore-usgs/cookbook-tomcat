require "spec_helper"

cache_dir = '/tmp'

describe "wsi_tomcat::commons_daemon" do
  let (:chef_run) do |_runner|
    ChefSpec::SoloRunner.new(file_cache_path: cache_dir) do |runner|
      runner.node.default[:wsi_tomcat][:user][:home_dir] = "/opt/tomcat"
      runner.node.default[:java][:java_home] = "/usr/lib/jvm/java"
      runner.node.default[:wsi_tomcat][:user][:name] = "tomcat"
      runner.node.default[:wsi_tomcat][:group][:name] = "tomcat"
    end.converge(described_recipe)
  end

  before do
    stub_command("test -n \"$(ls -A #{cache_dir}/opt/commons_daemon)\"").and_return(false)
    # https://github.com/sethvargo/chefspec/issues/250
    allow(File).to receive(:exist?).and_call_original
  end

  it 'Creates BDCP Unpack directory' do
    expect(chef_run).to create_directory("#{cache_dir}/opt/commons_daemon").with(
      user:   'tomcat',
      group:  'tomcat'
    )
  end

  it "unpacks the commons daemon archive" do
    expect(chef_run).to run_execute("/bin/tar xvf /opt/tomcat/bin/commons-daemon-native.tar.gz --strip=1 -C #{cache_dir}/opt/commons_daemon").with(
      user: "tomcat",
      group: "tomcat"
    )
  end

  it "runs configure on BCDP source" do
    expect(chef_run).to run_execute("./configure --with-java=/usr/lib/jvm/java").with(
      user: "tomcat",
      group: "tomcat",
      cwd: "#{cache_dir}/opt/commons_daemon/unix"
    )
  end

  it "runs make on BCDP source to make jsvc binary" do
    expect(chef_run).to run_execute("make").with(
      user: "tomcat",
      group: "tomcat",
      cwd: "#{cache_dir}/opt/commons_daemon/unix"
    )
  end

  it "copies BCDP executable to tomcat's bin directory" do
    expect(chef_run).to run_execute("/bin/cp #{cache_dir}/opt/commons_daemon/unix/jsvc  /opt/tomcat/bin")
  end

  it "sets permissions on BCDP executable" do
    allow(File).to receive(:exist?).with('/opt/tomcat/bin/jsvc').and_return(true)

    expect(chef_run).to create_file("/opt/tomcat/bin/jsvc").with(
      mode: 0555,
      user: "tomcat",
      group: "tomcat"
    )
  end

end
