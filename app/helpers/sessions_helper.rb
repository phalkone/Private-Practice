module SessionsHelper

  def sign_in(user)
    session[:remember_token] = [user.id,user.salt]
    current_user = user
  end

  def sign_in_with_cookie(user)
    cookies.signed[:remember_token] = { :value =>  [user.id, user.salt], 
                                        :expires => 2.weeks.from_now }
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

  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || session[:remember_token] || [nil, nil]
    end


end
