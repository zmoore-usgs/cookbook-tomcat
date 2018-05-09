if defined?(ChefSpec)
  def create_instance(name)
    ChefSpec::Matchers::ResourceMatcher.new(:tomcat_instance, :create, name)
  end
end
