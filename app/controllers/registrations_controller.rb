class RegistrationsController < Devise::RegistrationsController

  
  protected

  def update_resource(resource, params)
    if current_user.provider == "linkedin"
      params.delete("current_password")
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  def after_update_path_for(resource)
    if current_user.connections.nil?
    	profiles_path
    else
    	profile_path(current_user.profile)
    end
  end

end