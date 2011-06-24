# == Schema Information
# Schema version: 20110112082837
#
# Table name: images
#
#  id          :integer         not null, primary key
#  picture     :binary
#  name        :string(255)
#  filetype    :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Image < ActiveRecord::Base
  attr_accessible :picture, :filetype, :description, :name

  validates_presence_of :picture, :description, :name
  
  def to_param
    "#{name}"
  end
end
