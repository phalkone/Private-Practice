class ImagesController < ApplicationController
  before_filter :load

  def load
    @image = Image.new
    @images = Image.all
  end
  
  def show
    @image = Image.find_by_name(params[:id])
    send_data(@image.picture, :type => "image/"+@image.filetype)
  end

  def create
    @image = Image.new(params[:image])
    @image.picture = params[:file][:picture].read
    if @image.save
      flash[:notice] = t("images.created")
    end
    redirect_to images_path
  end
  
  def new
  end
  
  def edit
    @image = Image.find_by_name(params[:id])
  end

  def index
  end

  def destroy
    @image = Image.find_by_name(params[:id])
    @image.destroy
    flash[:notice] = t("images.destroyed")
    @images = Image.all
  end

  def update
    @image = Image.find_by_name(params[:id])
    if @image.update_attributes(params[:image])
      flash[:notice] = t("images.updated")
      @image = Image.new
      @images = Image.all
    end
  end

  def edit
    @image = Image.find_by_name(params[:id])
  end

end
