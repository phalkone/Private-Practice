module SessionsHelper

  def sign_in(user, remember = "0")
    if remember == "1"
      cookies.signed[:remember_token] = { :value =>  [user.id, user.salt], 
                                          :expires => 2.weeks.from_now,
                                          :domain => request.domain }
    else
      session[:remember_token] = [user.id,user.salt]
    end
    current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    cookies.delete(:remember_token, 
                   :domain => request.domain) if cookies.signed[:remember_token]
    session[:remember_token] = nil 
    self.current_user = nil
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
    current_user.roles.exists?(:title => roletitle) unless !signed_in?
  end

  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || session[:remember_token] || [nil, nil]
    end


end
