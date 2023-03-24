class ImagesController < ApplicationController
  def new
    @image = Image.new
  end

  def create
    image = Image.new(image_params)
    image.processed_image = image_params[:original_image]
    if image.save
      redirect_to image_path(image)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @image = Image.find(params[:id])
  end

  private

  def image_params
    params.require(:image).permit(:original_image)
  end
end
