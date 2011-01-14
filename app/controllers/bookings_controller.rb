class BookingsController < ApplicationController

  def index
    @title= t("bookings.title")
    @doctor = (params[:doctor]) ? params[:doctor] : Role.where("title = ?","doctor").first.users.order("last_name ASC").first.id
    @begin_date = (params[:begin]) ? Time.new(params[:begin][:year].to_i, params[:begin][:month].to_i, params[:begin][:day].to_i,0,0,0, Time.now.utc_offset) : Time.now.beginning_of_day
    @end_date = (params[:end]) ?  Time.new(params[:end][:year].to_i, params[:end][:month].to_i, params[:end][:day].to_i,23,59,59, Time.now.utc_offset) : Time.now.advance(:days => 7).end_of_day
    @appointments = Appointment.where("begin >= ? AND ? >= begin AND doctor_id = ? AND patient_id IS NULL", @begin_date, @end_date, @doctor).order("begin ASC").all
  end

  def new
    @main_id = params[:booking][:main_id].to_i
    @sub_id = params[:booking][:sub_id].to_i
    @appointment = Appointment.find_by_id(@main_id).sub_appointments[@sub_id]
  end

  def  create
    if @appointment = Appointment.find_by_id(params[:main_id].to_i).book(current_user.id, params[:sub_id].to_i)
      flash[:notice] = "Succes"
    end
    redirect_to bookings_path
  end

end
