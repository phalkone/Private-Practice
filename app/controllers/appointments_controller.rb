class AppointmentsController < ApplicationController
  before_filter :authenticate
 
  def index
    @title = t("appointments.menutitle")
    @date = Date.new(2010, 12, 20)
    @start = 6
    @stop = 18
    @begin = Time.new(@date.year,@date.month,@date.day,@start,0,0, Time.now.utc_offset)
    @end = Time.new(@date.year,@date.month,@date.day,@stop,0,0, Time.now.utc_offset)
    @appointments = current_user.appointments.where("begin >= ? AND end <= ?", @begin , @end).order("begin ASC")
  end

  def new
     @appointment = Appointment.new
  end

  def create
    @appointment = current_user.appointments.build(params[:appointment])
    if @appointment.save
      flash.now[:notice] = t("appointments.created")
    end
  end

  def refresh
    datesplit = params["view"]["date"].split(" ")
    @date = Date.new(datesplit[0].to_i,datesplit[1].to_i,datesplit[2].to_i)
    @start = params["view"]["start"].to_i
    @stop = params["view"]["stop"].to_i
    @begin = Time.new(@date.year,@date.month,@date.day,@start,0,0, Time.now.utc_offset)
    @end = Time.new(@date.year,@date.month,@date.day,@stop,0,0, Time.now.utc_offset)
    @appointments = current_user.appointments.where("begin >= ? AND end <= ?", @begin , @end).order("begin ASC")
  end

  private
    def authenticate
      deny_access unless role?("doctor")
    end
end
