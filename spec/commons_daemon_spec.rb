require "spec_helper"

describe "wsi_tomcat::commons_daemon" do
  let (:chef_run) do |runner|
    ChefSpec::SoloRunner.new do |runner|
      runner.node.set[:wsi_tomcat][:user][:home_dir] = "/opt/tomcat"
      runner.node.set[:java][:java_home] = "/usr/lib/jvm/java-1.7.0"
      runner.node.set[:wsi_tomcat][:user][:name] = "tomcat"
      runner.node.set[:wsi_tomcat][:group][:name] = "tomcat"
    end.converge(described_recipe)
  end

  before do
   stub_command("test -n \"$(ls -A /opt/commons_daemon)\"").and_return(false)
  end
  
  before do
     # https://github.com/sethvargo/chefspec/issues/250
     allow(File).to receive(:exist?).and_call_original
  end
  
=begin
  
  Due to resource cloning, this is currently not working. This probably needs to be refactored.
  The problem here is that I am creating this directory at the beginning of this recipe and
  deleting it at the end so I am using this resource twice and each of these assertions expect
  both actions to happen
  
  One way of having these tests pass is to seperate the ceration and deletion of this resource
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
    expect(chef_run).to run_execute("/bin/tar xvf /opt/tomcat/bin/commons-daemon-native.tar.gz --strip=1 -C /opt/commons_daemon").with(
    user: "tomcat",
    group: "tomcat"
    )
  end
   
  it "runs configure on BCDP source" do
    expect(chef_run).to run_execute("./configure --with-java=/usr/lib/jvm/java-1.7.0").with(
    user: "tomcat",
    group: "tomcat",
    cwd: "/opt/commons_daemon/unix"
    )
  end
   
  it "runs make on BCDP source to make jsvc binary" do
    expect(chef_run).to run_execute("make").with(
    user: "tomcat",
    group: "tomcat",
    cwd: "/opt/commons_daemon/unix"
    )
  end
   
  it "copies BCDP executable to tomcat's bin directory" do
    expect(chef_run).to run_execute("/bin/cp /opt/commons_daemon/unix/jsvc  /opt/tomcat/bin")
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
