class MessagesController < ApplicationController
  before_filter :authenticate, :only => [:show, :destroy]
  
  def new
    @title = t("messages.contact")
    @menu_active = "contact"
    @doctors = Role.where("title = ?","doctor").first.users.order("last_name ASC")
    if params[:doctor]
      @user = User.find(params[:doctor])
      @doctor = @user.roles.exists?(:title => "doctor") ? @user : @doctors.first
    else
      @doctor = @doctors.first
    end
    @message = Message.new
    if signed_in?
      @message.name = current_user.name
      @message.email = current_user.email
    end
  end
  
  def create
    @doctor = User.find(params[:message][:user])
    @message = @doctor.messages.build(params[:message])
    if @doctor.save
      @message.deliver
      flash[:notice] = t("messages.message_send")
      redirect_to Page.order("sequence ASC").first unless Page.count == 0
    else
      @title = t("messages.contact")
      @menu_active = "contact"
      @doctors = Role.where("title = ?","doctor").first.users.order("last_name ASC")
      render "new"
    end
  end
   
  def update_contact
    @doctors = Role.where("title = ?","doctor").first.users.order("last_name ASC")
    @user = User.find(params[:id])
    @doctor = @user.roles.exists?(:title => "doctor") ? @user : @doctors.first
  end
  
  def show
    @message = Message.find(params[:id])
    @message.mark_read
    @title = @message.user.name
    @menu_active = "profile" if (@message.user.id == current_user.id)
  end
  
  def destroy
    @message = Message.find(params[:id])
    @user = User.find(@message.user.id)
    if @message.destroy
      flash[:notice] = t("messages.deleted")
      redirect_to messages_user_path(@user)
    end
  end
    
  private
    def authenticate
      if !signed_in?
        deny_access
      else
        @user = Message.find(params[:id]).user
        deny_access unless current_user?(@user) || role?("admin")
      end
    end
  
end
