if defined?(ChefSpec)
  def create_instance(name)
    ChefSpec::Matchers::ResourceMatcher.new(:wsi_tomcat_instance, :create, name)
  end
end
