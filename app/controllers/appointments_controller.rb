class AppointmentsController < ApplicationController
  before_filter :authenticate
  respond_to :html, :js, :json
 
  def index
    @title = t("appointments.menutitle")
    respond_to do |format|
      format.html
      format.json  { render :json => current_user.appointments.where("(begin >= ? AND begin < ?) OR (end > ? AND end <= ?)", Time.at(params[:begintime].to_i).utc.to_formatted_s(:db), Time.at(params[:endtime].to_i).utc.to_formatted_s(:db), Time.at(params[:begintime].to_i).utc.to_formatted_s(:db), Time.at(params[:endtime].to_i).utc.to_formatted_s(:db)).order("begin ASC").to_json(
        :include => {:patient => {:only => [:id, :first_name, :last_name]}},
        :only => [:id, :begin, :end, :split, :patient_id]) }
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    @subid = params[:sub_id].to_i if params[:sub_id]
  end

  def new
    @appointment = (params[:appointment]) ? Appointment.new(params[:appointment]) : Appointment.new
    if params[:appointment]
      @appointment.convert_begin_time
      @appointment.convert_end_time
    end
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
  
  def move
    @appointment = Appointment.find(params[:id])
    @begintime = Time.at(params[:begintime].to_i).utc
    @endtime = Time.at(params[:endtime].to_i).utc
    if !@appointment.update_attributes({:begin => @begintime, :end => @endtime})
      flash.now[:alert] = t("appointments.error_move")
    end
  end

  private
    def authenticate
      deny_access unless role?("doctor")
    end
end
