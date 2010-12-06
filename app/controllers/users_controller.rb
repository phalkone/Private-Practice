class UsersController < ApplicationController
  
  def index
    @users = User.all
    @title = t("users.menutitle")
  end

  def new
    @user = User.new
    @title = t("users.newtitle")
    @submit_text = t("users.submit.new");
  end

   def create
    @user = User.new(params[:user])
    if params[:role]
      params[:role].each do |role_id, on|
        @user.roles << Role.find(role_id)
      end
    end
    if @user.save
      sign_in @user
      flash[:notice] = t("users.created")
      redirect_to @user
    else
      @title = t("users.newtitle")
      @submit_text = t("users.submit.new");
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @title = t("users.edittitle")
    @submit_text = t("users.submit.edit");
  end

   def update
    @user = User.find(params[:id])
    @user.roles.clear
    if params[:role]
      params[:role].each do |role_id, on|
        @user.roles << Role.find(role_id)
      end
    end
    if @user.update_attributes(params[:user])
      sign_in @user
      flash[:notice] = t("users.edited")
      redirect_to @user
    else
      @title = t("users.edittitle")
      @submit_text = t("users.submit.edit");
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:alert] = t("users.destroyed")
    redirect_to users_url
  end

  def show
    @user = User.find(params[:id])
    @title = @user.first_name + " " + @user.last_name
  end

end
