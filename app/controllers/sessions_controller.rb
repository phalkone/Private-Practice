class SessionsController < ApplicationController
  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])

    if user.nil?
      flash[:error] = t("txt.invalid")
      redirect_back_or_default
    else
      sign_in(user,params[:session][:remember])
      redirect_to user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
