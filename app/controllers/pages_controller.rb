class PagesController < ApplicationController

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
    flash[:notice] = "Success"
  end

  def edit
    @page = Page.find(params[:id].to_i)
  end

  def show
    @page = Page.find(params[:id].to_i)
  end

  def update
    @page = Page.find(params[:id].to_i)
    if page.update_attributes(params[:page])
      flash[:notice] = t("pages.updated")
      @pages = Page.all
    end
  end

  def destroy
    @page = Page.find(params[:id].to_i)
    @page.destroy
    flash[:notice] = t("pages.destroyed")
    @pages = Page.all
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = t("pages.created")
      @pages = Page.all
    end
  end
end
