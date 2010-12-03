class ImagesController < ApplicationController
  
  def show
    @image = Image.find_by_name(params[:id])
    send_data(@image.picture, :type => "image/"+@image.filetype)
  end

  def create
    @image = Image.new(params[:image])
    if params[:image][:filetype] != ""
      @image.picture = params[:file][:picture].read
    end
    if @image.save
      flash[:notice] = t("images.created")
      redirect_to images_path
    else
      @images = Image.all
      render :template => "images/index"
    end
  end
  
  def new
    render :new, :layout => "blank"
  end
  
  def edit
    @image = Image.find_by_name(params[:id])
  end

  def index
    @title = t("images.title")
    @images = Image.all
    if !@image
      @image = Image.new
    end
  end

  def destroy
    @image = Image.find_by_name(params[:id])
    @image.destroy
    flash.now[:alert] = t("images.destroyed")
    @images = Image.all
  end

  def update
    @image = Image.find_by_name(params[:id])
    if @image.update_attributes(params[:image])
      flash.now[:notice] = t("images.updated")
      @image = Image.new
      @images = Image.all
    end
  end

  def edit
    @image = Image.find_by_name(params[:id])
  end

end
