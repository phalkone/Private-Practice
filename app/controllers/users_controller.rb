class UsersController < ApplicationController
  before_filter :admin, :only => [:roles,:update_roles]
  before_filter :admin_doctor, :only => [:index,:destroy]
  before_filter :logged_in, :only => [:edit,:update,:show]
  before_filter :correct_user, :only => [:edit,:update,:show]
    
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
    if params[:commit][t("users.submit.cancel")]
      if (role?("admin") || role?("doctor"))
        redirect_to users_path
      else
        redirect_to root_path
      end
    else
      params[:user][:super_reg] = "1" if (role?("admin") || role?("doctor"))
      if @user.save
        sign_in @user unless role?("admin") || role?("doctor")
        flash[:notice] = t("users.created")
        redirect_to @user
      else
        @title = t("users.newtitle")
        @submit_text = t("users.submit.new");
        render 'new'
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @title = t("users.edittitle")
    @submit_text = t("users.submit.edit");
  end

   def update
    @user = User.find(params[:id])
    if params[:commit][t("users.submit.cancel")]
      redirect_to @user
    else
      params[:user][:super_reg] = "1" if (role?("admin") || role?("doctor"))
      if @user.update_attributes(params[:user])
        sign_in @user unless role?("admin") || role?("doctor")
        flash[:notice] = t("users.edited")
        redirect_to @user
      else
        @title = t("users.edittitle")
        @submit_text = t("users.submit.edit");
        render 'edit'
      end
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
    @title = @user.name
  end

  def roles
    @user = User.find(params[:id])
    @title = @user.name
  end

  def update_roles
    @user = User.find(params[:id])
    if params[:commit][t("users.submit.cancel")]
      redirect_to @user
    else
      @user.roles.clear
      if params[:role]
        params[:role].each do |role_id, on|
          @user.roles << Role.find(role_id)
        end
      end
      redirect_to @user
    end
  end

  private
    def admin
      deny_access unless role?("admin")
    end

    def admin_doctor
      deny_access unless role?("admin") || role?("doctor")
    end

    def logged_in
      deny_access unless signed_in?
    end

    def correct_user
     @user = User.find(params[:id])
     redirect_to(root_path) unless current_user?(@user) || role?("admin") || role?("doctor")
    end

end
