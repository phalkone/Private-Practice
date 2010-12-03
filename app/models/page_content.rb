class PageContent < ActiveRecord::Base
  belongs_to :page

  attr_accessible :title, :body, :html, :locale

  validates_presence_of :title, :body
  validates_length_of :title, :maximum => 30
  validates_length_of :body, :maximum => 10000

end
