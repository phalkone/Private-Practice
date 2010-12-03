class PagesController < ApplicationController
  
  def index
    session[:locale] = I18n.locale
    @title = t("pages.title")
    @pages = Page.order("sequence ASC").all
  end
 
  def new
    @page_content = Page.new.page_contents.new
    @submit_text = t("pages.submit.new");
    render :action => "open"
  end

  def create
    if params[:id] 
      @page = Page.find(params[:id].to_i)
    else
      sequence = (Page.count > 1) ? (Page.order("sequence ASC").last.sequence + 1) : 1
      @page = Page.new({ :nested => false, 
                         :sequence => sequence,
                         :permalink => params[:page_content][:title]
                          .downcase.gsub(/\s+/, '_').gsub(/[^a-zA-Z0-9_]+/, '')})
    end
    @page_content = @page.page_contents.build(params[:page_content])
    if @page.save
      flash[:notice] = t("pages.created")
      @pages = Page.order("sequence ASC").all
    else
      @page_content = @page.page_contents.first
      @images = Image.all
      @submit_text = t("pages.submit.new");
    end
    render :action => "save"
  end

  def edit
    @page = Page.find(params[:id].to_i)
    @page_content = @page.get_content(session[:locale])
    @submit_text = t("pages.submit.edit");
    render :action => "open"
  end

  def update
    @page = Page.find(params[:id].to_i)
    @page_content = @page.get_content(session[:locale])
    if @page_content.update_attributes(params[:page_content])
      flash[:notice] = t("pages.updated")
      first_not_nested
      @pages = Page.order("sequence ASC").all
    else
      @submit_text = t("pages.submit.edit");
    end
    render :action => "save"
  end

  def homepage
    redirect_to Page.order("sequence ASC").first unless Page.count == 0
  end

  def show
    @menu = Page.where("nested = ?",false).order("sequence ASC")
    @page = Page.find(params[:id].to_i)
    @title = @page.get_content(I18n.locale).title
    if @page.nested
      @main_page = Page.where("nested = ?", false)
        .where("sequence < ?",@page.sequence)
        .order("sequence DESC").first
    else
      @main_page = @page
    end
    next_page = Page.where("sequence > ?",@main_page.sequence)
      .where("nested = ?", false).order("sequence ASC").first
    if next_page
      @subpages = Page.where("sequence >= ?",@main_page.sequence)
        .where("sequence < ?",next_page.sequence).order("sequence ASC")
    else
      @subpages = Page.where("sequence >= ?",@main_page.sequence)
        .order("sequence ASC")
    end
    if @subpages and @subpages.count == 1
      @subpages = nil
    end
  end

  def destroy
    @page = Page.find(params[:id].to_i)
    @page.destroy
    flash[:notice] = t("pages.destroyed")
    first_not_nested unless Page.count == 0
    @pages = Page.order("sequence ASC").all
    render :action => "refresh"
  end
  
  def toggle
    page = Page.find(params[:id].to_i)
    nested = (page.nested) ? false : true
    page.update_attributes(:nested => nested)
    @pages = Page.order("sequence ASC").all
    render :action => "refresh"
  end
  
  def up
    page = Page.find(params[:id].to_i)
    prev_page = Page.where("sequence < ?",page.sequence).order("sequence DESC").first
    if prev_page
      switch(page, prev_page)
    end
  end
  
  def down
    page = Page.find(params[:id].to_i)
    next_page = Page.where("sequence > ?",page.sequence).order("sequence ASC").first
    if next_page
      switch(Page.find(params[:id].to_i), next_page)
    end
  end

  def changelocale
    session[:locale] = (params[:new_locale]) ? params[:new_locale] : I18n.locale
    @pages = Page.order("sequence ASC").all
    render :action => "refresh"
  end
  
  def refresh
  end

  def save
  end

  def open
  end

  private
    def first_not_nested
      first_page = Page.order("sequence ASC").first
      if first_page.nested
        first_page.update_attributes(:nested => false)
      end
    end
    
    def switch(page, other_page)
      new_seq = other_page.sequence
      other_page.update_attributes(:sequence => page.sequence)
      page.update_attributes(:sequence => new_seq)
      first_not_nested
      @pages = Page.order("sequence ASC").all
      render :action => "refresh"
    end

end
