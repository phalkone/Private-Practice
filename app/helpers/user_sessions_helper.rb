module UserSessionsHelper
  
  def current_session
    return @current_session if defined?(@current_session)
    @current_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_session && current_session.record
  end

  def signed_in?
    !current_user.nil?
  end
  
  def current_user?(user)
     user == current_user
  end
  
  def deny_access
    store_location
    redirect_to signin_path, :alert => t("txt.deny")
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def return_to_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  def clear_return_to
    session[:return_to] = nil
  end
  
  def role?(roletitle)
    signed_in? ? current_user.roles.exists?(:title => roletitle) : false
  end
  
end
