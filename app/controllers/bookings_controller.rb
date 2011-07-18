class BookingsController < ApplicationController
  before_filter :logged_in
  before_filter :correct_user, :only => :show

  def index
    @title= t("bookings.title")
    @year = params[:year] ? params[:year].to_i : Date.current.year
    @month = params[:month] ? params[:month].to_i : Date.current.month
    @day = params[:day] ? params[:day].to_i : Date.current.day
    @selected = Date.civil(@year,@month,@day)
    @begin_week = @selected.to_datetime.at_beginning_of_week
    @end_week =  @selected.to_datetime.at_end_of_week
    @doctors = Role.where("title = ?","doctor").first.users.order("last_name ASC")
    if params[:doctor]
      @user = User.find(params[:doctor])
      @doctor = @user.roles.exists?(:title => "doctor") ? @user : @doctors.first
    else
      @doctor = @doctors.first
    end
    # TODO only futue appointments
    @appointments = @doctor.appointments.unbooked.where("begin >= ? AND ? >= begin", @begin_week, @end_week).order("begin ASC")
    @weekend = ((@appointments.count != 0) && (@appointments.last.end > @end_week.advance(:days => -2)))? 7 : 5
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
