class BookingsController < ApplicationController
  before_filter :logged_in
  before_filter :correct_user, :only => :show

  def index
    @title= t("bookings.title")
    @doctor = (params[:doctor]) ? params[:doctor] : Role.where("title = ?","doctor").first.users.order("last_name ASC").first.id
    if !(params[:begin]) || !(@begin_date = Time.new(params[:begin][:year].to_i, params[:begin][:month].to_i, params[:begin][:day].to_i,0,0,0, Time.now.utc_offset)) || (@begin_date < Time.now.beginning_of_day)
      @begin_date = Time.now
      @form = true
    end
    if !(params[:end]) || !(@end_date = Time.new(params[:end][:year].to_i, params[:end][:month].to_i, params[:end][:day].to_i,23,59,59, Time.now.utc_offset)) || (@end_date < Time.now)
      @end_date = Time.now.advance(:days => 7).end_of_day
      @form = true
    end
    if @end_date < @begin_date
      temp = @end_date
      @end_date = @begin_date
      @begin_date = temp
      @form = true
    end
    @appointments = Appointment.where("begin >= ? AND ? >= begin AND doctor_id = ? AND patient_id IS NULL", @begin_date, @end_date, @doctor).order("begin ASC").all
  end
  
  def show
    @user = User.find(params[:id])
    @title = @user.name
    @menu_active = (@user.id == current_user.id) ? "profile" : "users"
  end

  def new
    @main_id = params[:booking][:main_id].to_i
    @sub_id = params[:booking][:sub_id].to_i
    @appointment = Appointment.find_by_id(@main_id).sub_appointments[@sub_id]
    if (@appointment.begin < Time.now) || (!@appointment.unbooked?)
      redirect_to bookings_path
    end
  end

  def  create
    if @appointment = Appointment.find_by_id(params[:main_id].to_i).book(current_user.id, params[:sub_id].to_i, params[:comment])
      redirect_to user_path(current_user), :notice => t("bookings.success")
    else
      flash.now[:alert] = t("bookings.failure")
      @main_id = params[:main_id].to_i
      @sub_id = params[:sub_id].to_i
      @appointment = Appointment.find_by_id(@main_id).sub_appointments[@sub_id]
      @appointment.comment = params[:comment]
      render "new"
    end
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    @user = @appointment.patient
    if( (current_user?(@user) && (@appointment.begin > Time.now)) || role?("admin") || role?("doctor"))
      @appointment.unbook
      redirect_to user_path(@user), :alert => t("bookings.cancelled")
    else
      deny_access
    end
  end

 private
    def logged_in
      deny_access unless signed_in?
    end
    
    def correct_user
     @user = User.find(params[:id])
     redirect_to(root_path) unless current_user?(@user) || role?("admin") || role?("doctor")
    end
    

end
