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
