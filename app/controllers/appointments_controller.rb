class AppointmentsController < ApplicationController
  before_filter :authenticate
  respond_to :html, :js, :json
 
  def index
    @title = t("appointments.menutitle")
    if params["view"] 
      datesplit = params["view"]["date"].split(" ")
      @date = Date.new(datesplit[0].to_i,datesplit[1].to_i,datesplit[2].to_i)
      @start = params["view"]["start"].to_i
      @stop = params["view"]["stop"].to_i
      @dayweek = params["view"]["dayweek"]
      @weekend = params["view"]["weekend"].to_s
      cookies.permanent[:settings] = { 
       :value =>  @date.to_s + "*" + @start.to_s + "*" + @stop.to_s + "*" + @dayweek + "*" + @weekend, 
       :domain => request.domain }
    else
      if cookies[:settings]
        settings = cookies[:settings].split("*")
        datesplit = settings[0].split("-")
        @date = Date.new(datesplit[0].to_i,datesplit[1].to_i,datesplit[2].to_i)
        @start = settings[1].to_i
        @stop = settings[2].to_i
        @dayweek = settings[3]
        @weekend = settings[4]
      else
        @date = Date.today
        @start = 9
        @stop = 17
        @dayweek = "day"
        @weekend = "1"
      end
    end
    if @dayweek == "day"
      @begin = Time.new(@date.year,@date.month,@date.day,@start,0,0, Time.now.utc_offset)
      @end = Time.new(@date.year,@date.month,@date.day,@stop,0,0, Time.now.utc_offset)
      @appointments = current_user.appointments.where("(begin >= ? AND begin < ?) OR (end > ? AND end <= ?) OR (begin < ? AND end > ?)", @begin , @end, @begin , @end, @begin, @end).order("begin ASC")
      if (@appointments.count != 0) && (@appointments.last.end > @end)
        i = 0
        while (@appointments.last.sub_appointments[i].end < @end) && (@appointments.last.sub_appointments[i].end != @end) do
          i += 1
        end
        @stop = @appointments.last.sub_appointments[i].end.hour
        @stop += 1 if @appointments.last.sub_appointments[i].end.min > 0
      end
      if (@appointments.count != 0) && (@appointments.first.begin < @begin)
        i = @appointments.first.sub_appointments.size - 1
        while (@appointments.first.sub_appointments[i].begin > @begin) && (@appointments.first.sub_appointments[i].begin != @begin) do
          i -= 1
        end
        @start = @appointments.first.sub_appointments[i].begin.hour
      end
      @dayarray = dayarray(@start, @stop, @appointments)
      @maxcols = @dayarray.last[0];
    else
      @date = @date.to_time
      @begin = @date.at_beginning_of_week
      @end = (@weekend == "1") ? @date.at_end_of_week : @date.at_end_of_week.yesterday.yesterday
    end
  end
  
  def get_appointments
    @appointments = current_user.appointments.where("begin >= ? AND begin <= ?", params[:begintime] , params[:endtime])
    subapps = Array.new
    @appointments.each() do |app|
      app.sub_appointments.each() do |subapp|
        subapps << subapp
      end
    end
    
    #TODO  include correct json fields
    respond_to do |format|
      format.html { redirect_to appointments_path }
      format.json  { render :json => subapps.to_json(:include => {:patient => {:only => [:id, :first_name, :last_name]}}) }
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    @subid = params[:sub_id].to_i if params[:sub_id]
  end

  def new
    @appointment = (params[:appointment]) ? Appointment.new(params[:appointment]) : Appointment.new
    @appointment.convert_begin_time if params[:appointment]
    @appointment.convert_end_time if params[:appointment]
    @patient = User.new
    @title = t("appointments.newapp")
    @mode = "registered"
    render "open"
  end

  def create
    @appointment = current_user.appointments.build(params[:appointment])
    if(params[:user])
      @patient = User.new(params[:user])
      @patient.super_reg = (role?("admin") || role?("doctor"))
      @appointment.patient = @patient
      if @patient.save
        @mode = "registered"
        if @appointment.save
          flash.now[:notice] = t("appointments.created")
        else
          @mode = "registered"
        end
      else 
        @appointment.destroy if @appointment.save
        @mode = params[:view][:mode]
      end
    else
      if @appointment.save
        flash.now[:notice] = t("appointments.created")
      else
        @mode = params[:view][:mode]
      end
      @patient = User.new
    end
    render "save"
  end

  def edit
    @appointment = Appointment.find(params[:id])
    @appointment.date = l(@appointment.begin, :format => :datepicker)
    @appointment.begin_time = l(@appointment.begin.to_time, :format => :time)
    @appointment.end_time = l(@appointment.end.to_time, :format => :time)
    @patient = User.new
    @title = t("appointments.edit")
    if params[:mode]
      @mode = params[:mode]
    else
      @mode = (@appointment.unbooked?) ? "unbooked" : "registered" 
    end
    render "open"
  end

  def update
    @appointment = Appointment.find(params[:id])
    if(params[:user])
      @patient = User.new(params[:user])
      @patient.super_reg = (role?("admin") || role?("doctor"))
      @appointment.patient = @patient
      if @patient.save
        if @appointment.update_attributes(params[:appointment])
          flash.now[:notice] = t("appointments.updated")
        else
          @mode = "registered"
        end
      else
        @appointment.update_attributes(params[:appointment])
        @mode = params[:view][:mode]
      end
    else
      if params[:view][:mode] == "unbooked"
        @appointment.patient = nil
      end
      if @appointment.update_attributes(params[:appointment])
        flash.now[:notice] = t("appointments.updated")
      else
        @mode = params[:view][:mode]
      end
      @patient = User.new
    end
    render "save"
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    @appointment.destroy
    flash.now[:alert] = t("appointments.destroyed")
  end

  def unbook
    @appointment = Appointment.find(params[:id])
    @appointment.unbook
    flash.now[:alert] = t("bookings.cancelled")
    render "destroy"
  end

  private
    def authenticate
      deny_access unless role?("doctor")
    end
end
