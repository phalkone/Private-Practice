class EmailConfirmationsController < ApplicationController
   before_filter :load_user_using_perishable_token, :only => :show
   before_filter :authenticate, :only => [:edit,:update]

   def new
     @email = params[:email].nil? ? "" : params[:email]
     @title = t("email_confirmations.title")
   end
   
   def create
     @user = User.find_by_email(params[:user][:email])
     if @user
       @user.deliver_email_confirmation_instructions
       redirect_to Page.order("sequence ASC").first, :notice => t("email_confirmations.flash_request") unless Page.count == 0
     else
       flash.now[:notice] = t("email_confirmations.not_found_request")
       render "new"
     end  
   end
  
   def show
     @title = t("email_confirmations.title")
     @user.confirm
     sign_in(@user,false)
     redirect_to @user, :notice => t("email_confirmations.success")
   end
   
   def edit
     @title = t("email_confirmations.title")
     @user = User.find(params[:id])
   end

   def update
     @user = User.find(params[:id])
     if params[:commit][t("users.submit.cancel")]
       redirect_to @user
     else
       if @user.update_attributes(params[:user])
          @user.unconfirm
          @user.deliver_email_confirmation_instructions
          redirect_to Page.order("sequence ASC").first, :notice => t("email_confirmations.flash_success") unless Page.count == 0
        else
          @title = t("email_confirmations.title")
          render "edit"
        end
      end
   end

   private  
    def load_user_using_perishable_token
      sign_out
      @user = User.find_using_perishable_token(params[:id])  
      unless @user  
        flash[:notice] = @title = t("email_confirmations.not_found")
        redirect_to new_email_confirmation_path
      end
    end

    def authenticate
       @user = User.find(params[:id])
       redirect_to(root_path) unless current_user?(@user) || role?("admin") || role?("doctor")
    end
end
