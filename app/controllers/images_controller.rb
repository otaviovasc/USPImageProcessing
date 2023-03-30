class ImagesController < ApplicationController
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
    processed_image_url = output_lines[0]
    text_output = output_lines[1]

    @image = Image.new
    @image.original_image.attach(uploaded_image)

    processed_image_data = Cloudinary::Downloader.download(processed_image_url)
    @image.processed_image.attach(
      io: StringIO.new(processed_image_data),
      filename: File.basename(processed_image_url)
    )
    @image.text_output = text_output
    if @image.save
      # Delete the uploaded and processed images from the server
      FileUtils.rm_rf(Dir.glob(Rails.root.join('public', 'uploads', '*')))
      redirect_to @image
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
