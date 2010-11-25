class Page < ActiveRecord::Base
  before_create :perm_seq
  attr_accessible :title, :body, :nested, :sequence, :html

  validates_presence_of :title, :body
  validates_length_of :title, :maximum=>30
  validates_length_of :locale, :maximum=>2
  validates_length_of :body, :maximum=>10000

  def perm_seq
    @attributes['permalink'] = 
      title.downcase.gsub(/\s+/, '_').gsub(/[^a-zA-Z0-9_]+/, '')
    if Page.where("locale = ?",locale).count > 0 
      @last = Page.where("locale = ?",locale).order("sequence ASC").last
      @attributes['sequence'] = @last.sequence + 10
    else
      @attributes['sequence'] = 10
    end
  end

  def all
    return Page.where("locale = ?",session[:locale]).order("sequence ASC")
  end

  def to_param
    "#{id}-#{permalink}"
  end

end
