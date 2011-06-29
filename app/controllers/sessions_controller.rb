class SessionsController < ApplicationController
  def new
    @title = t("txt.signin")
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])

    if user.nil?
      @title = t("txt.signin")
      flash[:alert] = t("txt.invalid")
      render 'new'
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
