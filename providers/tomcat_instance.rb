def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "Tomcat instance #{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_tomcat_instance
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_tomcat_instance
    end
  else
    Chef::Log.info "Tomcat instance #{ @new_resource } doesnt exist - can't delete."
  end
end

def load_current_resource 
  @current_resource.name         = @new_resource.name
  @current_resource.home         = @new_resource.home
  @current_resource.port_number  = @new_resource.port_number
  @@current_resource.ssl_enabled = @new_resource.ssl_enabled
  
  if instance_exists?(@current_resource.home, @current_resource.name)
    @current_resource.exists     = true
  end
end

def instance_exists?(home, name)
  Chef::Log.debug "Checking to see if Tomcat instance '#{name}' exists"
  File.exists?(File.expand_path(home, name))
end

def create_tomcat_instance
    
end

def delete_tomcat_instance
  
end

