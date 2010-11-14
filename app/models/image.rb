class Image < ActiveRecord::Base
  attr_accessible :picture, :filetype, :description, :name

  validates_presence_of :picture, :filetype, :description, :name
  
  def to_param
    "#{name}"
  end
end
