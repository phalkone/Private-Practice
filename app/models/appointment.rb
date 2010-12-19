class Appointment < ActiveRecord::Base
  belongs_to :doctor, :class_name => "User",  :foreign_key => "doctor_id" 
  belongs_to :patient, :class_name => "User",  :foreign_key => "patient_id" 
end
