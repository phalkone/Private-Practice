class Page < ActiveRecord::Base
  attr_accessible :title, :body, :locale, :nested

  validates_presence_of :title, :body, :locale
  validates_length_of :title, :maximum=>30
  validates_length_of :locale, :maximum=>2
  validates_length_of :body, :maximum=>10000

  def before_create
    @attributes['permalink'] = 
      title.downcase.gsub(/\s+/, '_').gsub(/[^a-zA-Z0-9_]+/, '')
    if Page.where("locale = ?",locale).count > 0 
      @last = Page.where("locale = ?",locale).order("sequence ASC").last
      @attributes['sequence'] = @last.sequence + 10
    else
      @attributes['sequence'] = 10
    end
  end

end
