class SessionsController < ApplicationController
  def new
    @title = t("txt.signin")
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])

    if user.nil?
      redirect_to signin_path, :alert => t("txt.invalid")
    else
      sign_in(user,params[:session][:remember])
      return_to_or user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
