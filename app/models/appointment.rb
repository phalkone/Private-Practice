class Appointment < ActiveRecord::Base
  attr_accessor :date, :begin_time, :end_time

  belongs_to :doctor, :class_name => "User",  :foreign_key => "doctor_id" 
  belongs_to :patient, :class_name => "User",  :foreign_key => "patient_id"

  validate :overlap
  validates_presence_of :doctor_id
  validates_format_of :begin_time, :end_time, :with => /\A([0-2]*[0-9]):([0-5][0-9])\z/, :allow_nil => true
  validates_format_of :date, :with => /\A([0-3]*[0-9])\/([0-2][0-9])\/(20)([0-9][0-9])\z/, :allow_nil => true
  validates_presence_of :begin, :end, :message => I18n.t("appointments.invalid")
  validates_length_of :comment, :maximum => 1000
  validates_numericality_of :split, :only_integer => true, :allow_nil => true
  
  before_validation :convert_begin_time, :convert_end_time

  def overlap
    if self.begin and self.end
      appointment_id = self.id || 0

      if app = Appointment.where("begin <= ? AND ? < end AND id <> ? AND doctor_id = ? AND patient_id IS NOT NULL", self.begin, self.begin, appointment_id, self.doctor_id).first
        errors.add :begin_time, I18n.t("appointments.begin_invalid")
      elsif Appointment.where("begin < ? AND ? <= end AND id <> ? AND doctor_id = ? AND patient_id IS NOT NULL", self.end, self.end, appointment_id, self.doctor_id).first
        errors.add :end_time, I18n.t("appointments.end_invalid")
      elsif Appointment.where("begin > ? AND ? > end AND id <> ? AND doctor_id = ? AND patient_id IS NOT NULL", self.begin, self.end, appointment_id, self.doctor_id).first
        errors.add :duration, I18n.t("appointments.duration_invalid")
      else
        Appointment.destroy_all("begin >= '#{self.begin}' AND '#{self.end}' >= end AND id <> #{appointment_id} AND doctor_id = #{self.doctor_id} AND patient_id IS NULL")
        if app = Appointment.where("begin <= ? AND ? < end AND id <> ? AND doctor_id = ? AND patient_id IS NULL", self.begin, self.begin, appointment_id, self.doctor_id).first
          if (app.end > self.end)
            original_end = app.end
            app.update_attribute("end", self.begin)
            app.copy(self.end,original_end)
          else
            app.update_attribute("end", self.begin)
          end
        end
        if app = Appointment.where("begin < ? AND ? <= end AND id <> ? AND doctor_id = ? AND patient_id IS NULL", self.end, self.end, appointment_id, self.doctor_id).first
          app.update_attribute("begin", self.end) 
        end
      end

      errors.add :end_time, I18n.t("appointments.rev_invalid") if self.end < self.begin
    end
  end

  def convert_begin_time
    app_date = self.date.split('/')
    app_begin_time = self.begin_time.split(':')
    self.begin = DateTime.new(app_date[2].to_i,app_date[1].to_i,app_date[0].to_i,app_begin_time[0].to_i,app_begin_time[1].to_i,0)
    rescue
  end

  def convert_end_time
    app_date = self.date.split('/')
    app_end_time = self.end_time.split(':')
    self.end = DateTime.new(app_date[2].to_i,app_date[1].to_i,app_date[0].to_i,app_end_time[0].to_i,app_end_time[1].to_i,0)
    rescue
  end

  def begincell(start)
    min = (self.begin.min - (self.begin.min % 15))/15
    return (min + ((self.begin.hour-start)*4))
  end

  def endcell(start)
    return (begincell(start) + self.rowspan - 1)
  end

  def duration
    return ((self.end - self.begin)/60).to_i
  end

  def top
    (self.begin.min % 15)
  end

  def rowspan
    a = 15 - top
    
    dur = ((self.end - self.begin - (a*60))/900).to_i
    if (self.end - self.begin - (a*60)) <= 0
      dur = 1
    elsif ((self.end - self.begin - (a*60)) % 900) != 0
      dur += 2
    else
      dur += 1
    end
    return dur
  end

  def unbooked?
    return true if self.patient.nil?
  end

  def unbook
    self.update_attribute("patient_id", nil) 
  end

  def sub_appointments
    subapps = Array.new
    if(self.split.nil? || self.split == 0 || (self.begin.advance(:minutes => self.split) > self.end))
      subapps.insert(-1,self)
    else
      new_begin = self.begin
      new_end = self.begin.advance(:minutes => self.split)
      while new_end < self.end do
        subapp = Appointment.new(:doctor_id => self.doctor_id,
                                 :begin => new_begin,
                                 :end => new_end,
                                 :comment => self.comment )    
        subapps.insert(-1,subapp)
        new_begin = new_end
        new_end = new_end.advance(:minutes => self.split)
        if new_end >= self.end
          subapp = Appointment.new(:doctor_id => self.doctor_id,
                                   :begin => new_begin,
                                   :end => self.end,
                                   :comment => self.comment ) 
          subapps.insert(-1,subapp)
        end
      end
    end
    return subapps
  end

  protected
    def copy(begin_time, end_time)
      app = Appointment.new(:doctor_id => self.doctor_id,
                            :begin => begin_time,
                            :end => end_time,
                            :comment => self.comment,
                            :patient_id => self.patient_id,
                            :split => self.split )                         
      app.save
    end
end
