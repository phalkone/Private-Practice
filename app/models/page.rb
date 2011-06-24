# == Schema Information
# Schema version: 20110112082837
#
# Table name: pages
#
#  id         :integer         not null, primary key
#  permalink  :string(255)
#  nested     :boolean
#  sequence   :integer
#  created_at :datetime
#  updated_at :datetime
#

class Page < ActiveRecord::Base
  has_many :page_contents, :dependent => :destroy
  attr_accessible :nested, :sequence, :permalink

  def to_param
    "#{id}-#{permalink}"
  end

  def get_content(loc)
    if self.page_contents.where("locale = ?", loc).first
	self.page_contents.where("locale = ?", loc).first
    else
        page_contents.new({ 
         :title => self.page_contents.first.title + " (" + loc.to_s + " trans. missing)", 
         :body => loc.to_s + " TRANSLATION MISSING <br/><br/>" + self.page_contents.first.body,
         :html => self.page_contents.first.html,
         :locale => loc})
    end
  end

end
