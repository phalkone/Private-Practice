class PagesController < ApplicationController
  
  def index
    set_session_locale
    @title = t("pages.title")
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
  end
 
  def new
    @page = Page.new
    @submit_text = t("pages.submit.new");
    @images = Image.all
    render :action => "open"
  end

  def edit
    @page = Page.find(params[:id].to_i)
    @submit_text = t("pages.submit.edit");
    @images = Image.all
    render :action => "open"
  end

  def homepage
    set_session_locale
    redirect_to Page.where("locale = ?",session[:locale])
      .order("sequence ASC").first
  end

  def show
    set_session_locale
    @menu = Page.where("locale = ?",session[:locale])
      .where("nested = ?",false).order("sequence ASC")
    @page = Page.find(params[:id].to_i)
    @title = @page.title
    if @page.nested
      @main_page = Page.where("locale = ?",session[:locale])
        .where("nested = ?", false).where("sequence < ?",@page.sequence)
        .order("sequence DESC").first
    else
      @main_page = @page
    end
    next_page = Page.where("locale = ?",session[:locale])
      .where("sequence > ?",@main_page.sequence)
      .where("nested = ?", false).order("sequence ASC").first
    if next_page
      @subpages = Page.where("locale = ?",session[:locale])
        .where("sequence >= ?",@main_page.sequence)
        .where("sequence < ?",next_page.sequence).order("sequence ASC")
    else
      @subpages = Page.where("locale = ?",session[:locale])
        .where("sequence >= ?",@main_page.sequence)
        .order("sequence ASC")
    end
    if @subpages and @subpages.count == 1
      @subpages = nil
    end
  end

  def update
    @page = Page.find(params[:id].to_i)
    if @page.update_attributes(params[:page])
      flash[:notice] = t("pages.updated")
      first_not_nested
      @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    else
      @submit_text = t("pages.submit.edit");
    end
    render :action => "save"
  end

  def destroy
    @page = Page.find(params[:id].to_i)
    @page.destroy
    flash[:notice] = t("pages.destroyed")
    first_not_nested
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    render :action => "refresh"
  end
  
  def toggle
    @page = Page.find(params[:id].to_i)
    if @page.nested
      @page.update_attributes(:nested => false)
    else
      @page.update_attributes(:nested => true)
    end
    @page.save
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    render :action => "refresh"
  end
  
  def up
    @page = Page.find(params[:id].to_i)
    prev_page = Page.where("sequence < ?", @page.sequence)
      .where("locale = ?",session[:locale]).order("sequence DESC").first
    prev_prev_page = Page.where("sequence < ?", @page.sequence)
      .where("locale = ?",session[:locale]).order("sequence DESC").offset(1).first
    prev_prev_sequence = (prev_prev_page) ? prev_prev_page.sequence : 0
    new_seq = (prev_page.sequence + prev_prev_sequence)/2
    @page.update_attributes(:sequence => new_seq)
    if prev_prev_page.nil? 
      @page.update_attributes(:nested => false)
    end
    @page.save
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    render :action => "refresh"
  end
  
  def down
    @page = Page.find(params[:id].to_i)
    next_page = Page.where("sequence > ?", @page.sequence)
      .where("locale = ?",session[:locale]).order("sequence ASC").first
    next_next_page = Page.where("sequence > ?", @page.sequence)
      .where("locale = ?",session[:locale]).order("sequence ASC").offset(1).first
    next_next_sequence = (next_next_page) ? next_next_page.sequence : (next_page.sequence * 2)
    new_seq = (next_page.sequence + next_next_sequence)/2
    @page.update_attributes(:sequence => new_seq)
    @page.save
    first_not_nested
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    render :action => "refresh"
  end

  def create
    @page = Page.new(params[:page])
    @page.locale = session[:locale]
    if @page.save
      flash[:notice] = t("pages.created")
      @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    else
      @submit_text = t("pages.submit.new");
    end
    first_not_nested
    render :action => "save"
  end
  
  def changelocale
    set_session_locale
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    render :action => "refresh"
  end
  
  def refresh
  end

  def save
  end

  def open
  end

  private
    def set_session_locale
      session[:locale] = (params[:new_locale]) ? params[:new_locale] : I18n.locale 
    end
    
    def first_not_nested
      if Page.where("locale = ?",session[:locale]).first.nested
        first_page = Page.where("locale = ?",session[:locale]).first
        first_page.update_attributes(:nested => false)
        first_page.save
      end
    end
end
