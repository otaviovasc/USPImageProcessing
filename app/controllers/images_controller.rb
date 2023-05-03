class ImagesController < ApplicationController
  before_action :authenticate_user!, only: %i[create index show]
  def new
    @image = Image.new
  end

  def create
    # Get the uploaded image from the form
    uploaded_image = params[:image][:original_image]
    image_path = Cloudinary::Uploader.upload(uploaded_image.path)

    # Call the Python script with the image path as an argument
    python_output = `python3 python/hello_world.py #{image_path["url"]}`

    # Parse the output and save it to the @image instance
    output_lines = python_output.split("\n")
    base64_processed_image = output_lines[0]
    text_output = output_lines[1]

    # Decode image
    binary_data = Base64.decode64(base64_processed_image)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(binary_data)
    tempfile.rewind

    # Attach infos in a image instance
    image = Image.new
    image.original_image.attach(uploaded_image)
    image.processed_image.attach(io: tempfile, filename: 'image.png', content_type: 'image/png')
    image.text_output = text_output
    image.user = current_user

    if image.save
      # Delete the uploaded and processed images from the server
      redirect_to image, notice: "Imagem processada"
    else
      render :new, status: :unprocessable_entity
    end
    tempfile.close
    tempfile.unlink
  end

  def show
    @image = Image.find(params[:id])
  end

  def index
    @images = Image.where(user: current_user).sort_by(&:created_at).reverse
  end

  def destroy
    image = Image.find(params[:id])
    image.destroy
    redirect_to images_path, notice: "Imagem apagada com sucesso."
  end

  private

  def image_params
    params.require(:image).permit(:original_image)
  end
end
