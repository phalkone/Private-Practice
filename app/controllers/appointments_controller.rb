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
    @appointment = Appointment.new
    @patient = User.new
    @title = t("appointments.newapp")
    render "open"
  end

  def create
    @appointment = current_user.appointments.build(params[:appointment])
    if(params[:user])
      params[:user][:super_reg] = "1"
      @patient = User.new(params[:user])
      @appointment.patient = @patient
      if @patient.save && @appointment.save
        flash.now[:notice] = t("appointments.created")
      elsif @appointment.save
        @appointment.destroy
      end
    elsif @appointment.save
      flash.now[:notice] = t("appointments.created")
      @patient = User.new
    else
      @patient = User.new
    end
    
    render "save"
  end

  def edit
    @appointment = Appointment.find(params[:id])
    @appointment.date = l(@appointment.begin, :format => :datepicker)
    @appointment.begin_time = l(@appointment.begin.to_time, :format => :time)
    @appointment.end_time = l(@appointment.end.to_time, :format => :time)
    @begin_slider = (@appointment.begin.hour * 60) + @appointment.begin.min
    @end_slider = (@appointment.end.hour * 60) + @appointment.end.min
    @patient = User.new
    @title = t("appointments.edit")
    render "open"
  end

  def update
    @appointment = Appointment.find(params[:id])
    if(params[:user])
      params[:user][:super_reg] = "1"
      @patient = User.new(params[:user])
      @appointment.patient = @patient
      if @patient.save && @appointment.update_attributes(params[:appointment])
        flash.now[:notice] = t("appointments.updated")
      else
        @appointment.update_attributes(params[:appointment])
      end
    elsif @appointment.update_attributes(params[:appointment])
      flash.now[:notice] = t("appointments.updated")
      @patient = User.new
    else
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
      else
        @date = Date.new(2010, 12, 20)
        @start = 6
        @stop = 18
        @dayweek = "week"
        @weekend = "1"
      end
      if @dayweek == "day"
        @begin = Time.new(@date.year,@date.month,@date.day,@start,0,0, Time.now.utc_offset)
        @end = Time.new(@date.year,@date.month,@date.day,@stop,0,0, Time.now.utc_offset)
        @appointments = current_user.appointments.where("begin >= ? AND begin <= ?", @begin , @end).order("begin ASC")
        if (@appointments.count != 0) && (@appointments.last.end > @end)
          @stop = @appointments.last.end.hour + 1
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
    end
end
