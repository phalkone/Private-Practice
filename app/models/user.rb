class User < ActiveRecord::Base
  attr_accessor :password, :super_reg
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :super_reg

  has_and_belongs_to_many :roles

  has_many :appointments, :foreign_key => "doctor_id", :dependent => :destroy
  has_many :bookings, :class_name => "Appointment", :foreign_key => "patient_id"

  has_many :patients, :through => :appointments, :source => :patient, :uniq => :true
  has_many :doctors, :through => :bookings, :source => :doctor, :uniq => :true

  validates_presence_of :first_name, :last_name
  validates_presence_of :email, :if => :required?
  validates_length_of :first_name, :maximum => 30
  validates_length_of :last_name, :maximum => 30
  validates :email, :format     => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
                    :uniqueness => { :case_sensitive => false },
                    :allow_blank => true
  validates_presence_of :password, :if => (:new_record? && :required?)
  validates_confirmation_of :password
  validates_length_of :password, :within => 6..40, :allow_blank => true

  before_save :encrypt_password, :default_role, :blank_email

  def required?
    (self.super_reg) ? false : true
  end

  def blank_email
    self.email = (self.email.blank?) ? nil : self.email
  end

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def name
    self.last_name + ", " + self.first_name
  end

  private

    def encrypt_password
      return if password.blank?
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

    def default_role
      self.roles << Role.find_by_title('patient') if new_record?
    end

end
