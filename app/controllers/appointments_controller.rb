class AppointmentsController < ApplicationController
  before_filter :authenticate
 
  def index
    @title = t("appointments.menutitle")
    setValues
  end

  def show
    @appointment = Appointment.find(params[:id])
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
      params[:user][:super_reg] = "1"
      @patient = User.new(params[:user])
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
    @mode = (@appointment.unbooked?) ? "unbooked" : "registered" 
    render "open"
  end

  def update
    @appointment = Appointment.find(params[:id])
    if(params[:user])
      params[:user][:super_reg] = "1"
      @patient = User.new(params[:user])
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

  def refresh
    setValues
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    @appointment.destroy
    flash.now[:alert] = t("appointments.destroyed")
  end

  private
    def authenticate
      deny_access unless role?("doctor")
    end

    def setValues
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
        @appointments = current_user.appointments.where("(begin >= ? AND begin <= ?) OR (end >= ? AND end <= ?)", @begin , @end, @begin , @end).order("begin ASC")
        if (@appointments.count != 0) && (@appointments.last.end > @end)
          @stop = @appointments.last.end.hour + 1
        end
        if (@appointments.count != 0) && (@appointments.first.begin < @begin)
          @start = @appointments.first.begin.hour
        end
        @dayarray = dayarray(@start, @stop, @appointments)
        @maxcols = @dayarray.last[0];
      else
        @date = @date.to_time
        @begin = @date.at_beginning_of_week
        @end = (@weekend == "1") ? @date.at_end_of_week : @date.at_end_of_week.yesterday.yesterday
        @appointments = current_user.appointments.where("begin >= ? AND begin <= ?", @begin , @end).order("begin ASC")
        @weekarray = weekarray(@start, @stop, @appointments, @weekend)
      end
      @bookedcount = barray(@appointments)
    end
end
