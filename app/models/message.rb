# == Schema Information
# Schema version: 20110714002642
#
# Table name: messages
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  email      :string(255)
#  name       :string(255)
#  subject    :string(255)
#  body       :string(255)
#  read       :boolean         not null
#  created_at :datetime
#  updated_at :datetime
#

class Message < ActiveRecord::Base
  attr_accessible :name, :email, :subject, :body

  belongs_to :user
  
  has_one :patient, :class_name => "User", :primary_key => "email", :foreign_key => "email"
  
  validate :must_be_doctor

  validates_presence_of :name, :body, :email
  validates_length_of :name, :subject, :maximum => 30
  validates_length_of :body, :maximum => 10000
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    
  def must_be_doctor
    errors.add_to_base(t("messages.must_be_doctor")) unless self.user.roles.exists?(:title => "doctor")
  end
  
  def deliver
    UserMailer.contact_message(self).deliver
  end
  
  def mark_read
    self.update_attribute("read",true)
  end
  
  def mark_unread
    self.update_attribute("read",false)
  end
end
