class Appointment < ActiveRecord::Base
  attr_accessor :date, :begin_time, :end_time

  belongs_to :doctor, :class_name => "User",  :foreign_key => "doctor_id" 
  belongs_to :patient, :class_name => "User",  :foreign_key => "patient_id"

  validates_presence_of :doctor_id
  validates_format_of :begin_time, :end_time, :with => /\A([0-2]*[0-9]):([0-5][0-9])\z/
  validates_format_of :date, :with => /\A([0-3]*[0-9])\/([0-2][0-9])\/(20)([0-9][0-9])\z/
  validates_presence_of :begin, :end, :message => I18n.t("appointments.invalid")
  validates_length_of :comment, :maximum => 1000
  
  before_validation :convert_begin_time, :convert_end_time

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

  def dur
    return ((self.end - self.begin)/60).to_i
  end

  def top
    (self.begin.min % 15)
  end

  def bottom
    if (self.end.min % 15) == 0
      return 0
    else
      return 15 - (self.end.min % 15)
    end
  end

  def rowspan
    a = 15 - (self.begin.min % 15)
    
    duration = ((self.end - self.begin - (a*60))/900).to_i
    if (self.end - self.begin - (a*60)) <= 0
      duration = 1
    elsif ((self.end - self.begin - (a*60)) % 900) != 0
      duration += 2
    else
      duration += 1
    end
    return duration
  end
end
