class PasswordResetsController < ApplicationController
  before_filter :load_user, :only => [:edit, :update]
  before_filter :require_no_user, :only => [:new, :create]
  
  def new
    @title = t("password_resets.title")
  end
  
  def edit
     @title = t("password_resets.title")
  end
      
  def update
    if params[:commit][t("users.submit.cancel")]
      redirect_to @user
    else
      if @user.update_attributes(params[:user])
        flash[:notice] = t("password_resets.success")
        redirect_to @user
      else  
        render :action => :edit  
      end
    end
  end

  def create
    @user = User.find_by_email(params[:password_resets][:email])
    if @user
      @user.deliver_password_reset_instructions
      flash[:notice] = t("password_resets.flash_success")
      redirect_to Page.order("sequence ASC").first unless Page.count == 0
    else
      flash.now[:notice] = t("password_resets.flash_failure")
      render "new"
    end  
  end
  
  private  
    def load_user
      if signed_in?
        @user = User.find(params[:id])
        redirect_to(root_path) unless current_user?(@user) || role?("admin") || role?("doctor")
      else
        @user = User.find_using_perishable_token(params[:id])
      end

      unless @user  
        flash[:notice] = t("password_resets.not_found")
        redirect_to new_password_reset_path
      end
    end
    
    def require_no_user
      deny_access unless UserSession.find.nil?
    end
end
