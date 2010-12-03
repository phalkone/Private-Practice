class SessionsController < ApplicationController
  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])

    if user.nil?
      flash[:error] = t("txt.invalid")
      #redirect_back_or_default
    else
      (params[:session][:remember] == "1") ? sign_in_with_cookie(user) : sign_in(user)
      redirect_to user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
