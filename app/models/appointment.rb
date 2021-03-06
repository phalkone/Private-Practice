# == Schema Information
# Schema version: 20110112082837
#
# Table name: appointments
#
#  id         :integer         not null, primary key
#  doctor_id  :integer
#  patient_id :integer
#  begin      :datetime
#  end        :datetime
#  comment    :string(255)
#  recurrence :integer
#  completed  :boolean
#  created_at :datetime
#  updated_at :datetime
#  split      :integer
#

class Appointment < ActiveRecord::Base
  attr_accessor :date, :begin_time, :end_time, :sub_id, :main_id
  
  scope :unbooked, where(:patient_id => nil)
  scope :booked, where("patient_id IS NOT :null", :null => nil)

  belongs_to :doctor, :class_name => "User",  :foreign_key => "doctor_id" 
  belongs_to :patient, :class_name => "User",  :foreign_key => "patient_id"

  validate :overlap
  validates_presence_of :doctor_id
  validates_format_of :date, :with => /\A([0-3]*[0-9])\/([0-1][0-9])\/(20)([0-9][0-9])\z/, :allow_nil => true
  validates_length_of :comment, :maximum => 1000
  validates_numericality_of :split, :only_integer => true, :allow_nil => true
  
  before_validation :convert_begin_time, :convert_end_time

  def overlap
    errors.add :begin_time, I18n.t("appointments.invalid") if self.begin.nil?
    errors.add :end_time, I18n.t("appointments.invalid") if self.end.nil?

    if self.begin && self.end
      appointment_id = self.id || 0

      if app = Appointment.where("begin <= ? AND ? < end AND id <> ? AND doctor_id = ? AND patient_id IS NOT NULL", self.begin, self.begin, appointment_id, self.doctor_id).first
        errors.add :begin_time, I18n.t("appointments.begin_invalid")
      elsif Appointment.where("begin < ? AND ? <= end AND id <> ? AND doctor_id = ? AND patient_id IS NOT NULL", self.end, self.end, appointment_id, self.doctor_id).first
        errors.add :end_time, I18n.t("appointments.end_invalid")
      elsif Appointment.where("begin > ? AND ? > end AND id <> ? AND doctor_id = ? AND patient_id IS NOT NULL", self.begin, self.end, appointment_id, self.doctor_id).first
        errors.add :duration, I18n.t("appointments.duration_invalid")
      else
        Appointment.delete_all(["begin >= ? AND ? >= end AND id <> ? AND doctor_id = ? AND patient_id IS NULL",self.begin, self.end, appointment_id, self.doctor_id])
        if app = Appointment.where("begin < ? AND ? < end AND id <> ? AND doctor_id = ? AND patient_id IS NULL", self.begin, self.begin, appointment_id, self.doctor_id).first
          if (app.end > self.end)
            original_end = app.end
            app.copy(self.end,original_end)
            app.update_attribute("end", self.begin)
          else
            app.update_attribute("end", self.begin)
          end
        end
        if app = Appointment.where("begin < ? AND ? < end AND id <> ? AND doctor_id = ? AND patient_id IS NULL", self.end, self.end, appointment_id, self.doctor_id).first
          app.update_attribute("begin", self.end) 
        end
      end

      errors.add :end_time, I18n.t("appointments.rev_invalid") if self.end <= self.begin
    end
  end

  def convert_begin_time
    if self.begin_time && self.date
      app_date = self.date.split('/')
      app_begin_time = self.begin_time.split(':') if self.begin_time =~ /\A([0-2]*[0-9]):([0-5][0-9])\z/
      self.begin = DateTime.new(app_date[2].to_i,app_date[1].to_i,app_date[0].to_i,app_begin_time[0].to_i,app_begin_time[1].to_i,0)
    end
    rescue
      self.begin = nil
  end

  def convert_end_time
    if self.end_time && self.date
      app_date = self.date.split('/')
      app_end_time = self.end_time.split(':') if self.end_time =~ /\A([0-2]*[0-9]):([0-5][0-9])\z/
      self.end = DateTime.new(app_date[2].to_i,app_date[1].to_i,app_date[0].to_i,app_end_time[0].to_i,app_end_time[1].to_i,0)
    end
    rescue
      self.end = nil
  end

  def duration
    return ((self.end - self.begin)/60).to_i
  end

  def unbooked?
    return true if self.patient.nil?
  end

  # TODO fix me joining
  def unbook
    self.update_attribute("patient_id", nil)
    if ((app = Appointment.where("end = ? AND patient_id IS NULL",self.begin).first) && (app.split == self.duration))
      app.update_attribute("end", self.end)
      self.destroy
      if ((app2 = Appointment.where("begin = ? AND patient_id IS NULL",app.end).first) && (app2.split == app.split))
        app.update_attribute("end", app2.end)
        app2.destroy
      end
    elsif ((app = Appointment.where("begin = ? AND patient_id IS NULL",self.end).first) && (app.split == self.duration))
      app.update_attribute("begin", self.begin)
      self.destroy
    end
  end

  def book(patient_id,sub_id,comment)
    subapp = self.sub_appointments[sub_id]
    if subapp.patient_id.nil?
      subapp.patient_id = patient_id 
      subapp.comment = comment
    end
    if subapp.save
      return true
    else
      return false
    end
    rescue
      return false
  end

  def sub_appointments
    subapps = Array.new
    if((!self.unbooked?) || self.split.nil? || self.split == 0 || (self.begin.advance(:minutes => self.split) >= self.end))
      subapps.insert(-1,self)
      subapps[0].update_attributes(:sub_id => 0, :main_id => self.id)
    else
      new_begin = self.begin
      new_end = self.begin.advance(:minutes => self.split)
      while new_end < self.end do
        subapp = Appointment.new(:doctor_id => self.doctor_id,
                                 :begin => new_begin,
                                 :end => new_end,
                                 :comment => self.comment,
                                 :sub_id => subapps.size,
                                 :main_id => self.id )    
        subapps.insert(-1,subapp)
        new_begin = new_end
        new_end = new_end.advance(:minutes => self.split)
        if new_end >= self.end
          subapp = Appointment.new(:doctor_id => self.doctor_id,
                                   :begin => new_begin,
                                   :end => self.end,
                                   :comment => self.comment,
                                   :sub_id => subapps.size ,
                                   :main_id => self.id) 
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
