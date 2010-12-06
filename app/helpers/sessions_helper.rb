module SessionsHelper

  def sign_in(user, remember = "0")
    if remember == "1"
      cookies.signed[:remember_token] = { :value =>  [user.id, user.salt], 
                                          :expires => 2.weeks.from_now }
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
    cookies.delete(:remember_token) if cookies.signed[:remember_token]
    session[:remember_token] = nil 
    self.current_user = nil
  end

  def current_user?(user)
    user == current_user
  end

  def deny_access
    redirect_to signin_path, :notice => t("txt.deny")
  end

  def role?(user,roletitle)
    user.roles.exists?(:title => roletitle)
  end

  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || session[:remember_token] || [nil, nil]
    end


end
