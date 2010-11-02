class PagesController < ApplicationController

  def index
    set_session_locale
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
  end

  def new
    @page = Page.new
    @submit_text = t("pages.submit.new");
  end

  def edit
    @page = Page.find(params[:id].to_i)
    @submit_text = t("pages.submit.edit");
  end

  def show
    @page = Page.find(params[:id].to_i)
  end

  def update
    @page = Page.find(params[:id].to_i)
    if @page.update_attributes(params[:page])
      flash[:notice] = t("pages.updated")
      @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
    else
      @submit_text = t("pages.submit.edit");
    end
  end

  def destroy
    @page = Page.find(params[:id].to_i)
    @page.destroy
    flash[:notice] = t("pages.destroyed")
    @pages = Page.where("locale = ?",session[:locale]).order("sequence ASC")
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
  end

  private
    def set_session_locale
      if params[:new_locale] 
        session[:locale] = params[:new_locale]
      else
        session[:locale] = I18n.locale
      end
    end

end
