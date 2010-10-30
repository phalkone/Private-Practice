class PagesController < ApplicationController
  
  def index
    
  end
  
  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to(@page, :notice => t("pages.successful"))
    else
      render :action => "new"
    end
  end
end
