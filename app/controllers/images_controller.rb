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
    base64_processed_image = output_lines[0]
    text_output = output_lines[1]

    # Decode image
    binary_data = Base64.decode64(base64_processed_image)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(binary_data)
    tempfile.rewind


    @image = Image.new
    @image.original_image.attach(uploaded_image)
    # Attach processed image
    @image.processed_image.attach(io: tempfile, filename: 'image.png', content_type: 'image/png')
    @image.text_output = text_output
    if @image.save
      # Delete the uploaded and processed images from the server
      FileUtils.rm_rf(Dir.glob(Rails.root.join('public', 'uploads', '*')))
      redirect_to @image
    else
      render :new, status: :unprocessable_entity
    end

    tempfile.close
    tempfile.unlink
  end

  def show
    @image = Image.find(params[:id])
  end

  private

  def image_params
    params.require(:image).permit(:original_image)
  end
end
