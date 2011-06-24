# == Schema Information
# Schema version: 20110112082837
#
# Table name: page_contents
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  body       :text
#  locale     :string(255)
#  html       :boolean
#  page_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class PageContent < ActiveRecord::Base
  belongs_to :page

  attr_accessible :title, :body, :html, :locale

  validates_presence_of :title, :body
  validates_length_of :title, :maximum => 30
  validates_length_of :body, :maximum => 10000

end
