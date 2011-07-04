class UserSessionsController < ApplicationController
  
   def new
     @user_session = UserSession.new
     @title = t("txt.signin")
   end

   def create
     @title = t("txt.signin")
     @user_session = UserSession.new(params[:user_session])
     if @user_session.save
       return_to_or current_user
     else
       @title = t("txt.signin")
       render 'new'
     end
   end

   def destroy
     @user_session = UserSession.find
     @user_session.destroy
     redirect_to root_path
   end
end
