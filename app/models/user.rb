# == Schema Information
# Schema version: 20110701091404
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  email              :string(255)
#  crypted_password   :string(255)
#  password_salt      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  persistence_token  :string(255)
#  perishable_token   :string(255)
#  login_count        :integer         default(0), not null
#  failed_login_count :integer         default(0), not null
#  last_request_at    :datetime
#  current_login_at   :datetime
#  last_login_at      :datetime
#  current_login_ip   :string(255)
#  last_login_ip      :string(255)
#

class User < ActiveRecord::Base
  attr_accessor :super_reg
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation

  has_and_belongs_to_many :roles

  has_many :appointments, :foreign_key => "doctor_id", :dependent => :destroy
  has_many :bookings, :class_name => "Appointment", :foreign_key => "patient_id", :dependent => :nullify

  has_many :patients, :through => :appointments, :source => :patient, :uniq => :true
  has_many :doctors, :through => :bookings, :source => :doctor, :uniq => :true

  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :maximum => 30
  validates_length_of :last_name, :maximum => 30
  validates :email, :format     => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
                    :uniqueness => { :case_sensitive => false },
                    :presence => { :if => :required? },
                    :allow_blank => { :unless => :required?}
  validates :password,  :presence  => {:if => :password_required?},
                        :confirmation =>  {:if => :password_required?},
                        :length => {:within => 6..40},
                        :allow_blank => true
                        
  before_validation :blank_email
  before_save :default_role
  before_destroy :unbook_apps
  
  acts_as_authentic do |config|
     config.logged_in_timeout = 20.minutes
     config.login_field = :email
     config.validate_login_field = false
     config.validate_email_field = false
     config.validate_password_field = false
     config.require_password_confirmation = false
  end
  
   def blank_email
     self.email = (self.email.blank?) ? nil : self.email
   end
   
  def unbook_apps
    self.bookings.each() do |app|
      app.unbook
    end
  end
  
  def password_required?
     return (self.new_record? && self.required?)
  end

  def required?
    self.super_reg.nil? ? true : !self.super_reg
  end

  def name
    self.last_name + ", " + self.first_name
  end

  private

    def default_role
      self.roles << Role.find_by_title('patient') if new_record?
    end

end
