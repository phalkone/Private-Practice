class Appointment < ActiveRecord::Base
  belongs_to :doctor, :class_name => "User",  :foreign_key => "doctor_id" 
  belongs_to :patient, :class_name => "User",  :foreign_key => "patient_id"

  def begincell(start)
    min = (self.begin.min - (self.begin.min % 15))/15
    return (min + ((self.begin.hour-start)*4))
  end

  def endcell(start)
    return (begincell(start) + rowspan - 1)
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
