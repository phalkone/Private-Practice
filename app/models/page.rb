class Page < ActiveRecord::Base
  attr_accessible :title, :body, :locale

  validates_presence_of :title, :body, :permalink, :locale
  validates_length_of :title, :maximum=>30
  validates_length_of :locale, :maximum=>2
  validates_length_of :body, :maximum=>10000
end
