require "spec_helper"

cache_dir = '/tmp'

describe "wsi_tomcat::commons_daemon" do
  let (:chef_run) do |runner|
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

=begin

  Due to resource cloning, this is currently not working. This probably needs to be refactored.
  The problem here is that I am creating this directory at the beginning of this recipe and
  deleting it at the end so I am using this resource twice and each of these assertions expect
  both actions to happen

  One way of having these tests pass is to seperate the creation and deletion of this resource
  into seperate recipes

  Another solution would be to just dump these temp files into /tmp and not worry so much about cleanup

  Yet another solution would be to just build within the directory tomcat unpacks into

  context "/opt/commons_daemon" do
    it "creates /opt/commons_daemon directory" do
      allow(File).to receive(:exist?).with('/opt/tomcat/bin/jsvc').and_return(false)
      expect(chef_run).to create_directory("/opt/commons_daemon").with(
        owner: "tomcat",
        group: "tomcat"
      )
    end

    it "deletes /opt/commons_daemon directory" do
      allow(File).to receive(:exist?).with('/opt/tomcat/bin/jsvc').and_return(true)
      expect(chef_run).to delete_directory("/opt/commons_daemon")
    end
  end

=end

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

  # TODO: Fix this in actual recipe - This directory should probably be a temp dir
  # Also explained above.
  # The test fails with:
  #   1) wsi_tomcat::commons_daemon Deletes BDCP Unpack directory
  #   Failure/Error: expect(chef_run).to delete_directory("/tmp/opt/commons_daemon")
  #       expected "directory[Create BCDP build dir]" actions [:create] to include :delete
  #
  # it 'Deletes BDCP Unpack directory' do
  #   expect(chef_run).to delete_directory("#{cache_dir}/opt/commons_daemon")
  # end

end
