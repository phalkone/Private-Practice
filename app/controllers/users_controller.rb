class UsersController < ApplicationController
  def new
    @user = User.new
    @title = t("users.newtitle")
    @submit_text = t("users.submit.new");
  end

   def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:notice] = t("users.created")
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @title = @user.first_name + " " + @user.last_name
  end

end
