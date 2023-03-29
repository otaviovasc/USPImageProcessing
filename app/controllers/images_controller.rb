class ImagesController < ApplicationController
  def new
    @image = Image.new
  end

  def create
    # Get the uploaded image from the form
    uploaded_image = params[:image][:original_image]

    # Save the image to disk
    image_path = Rails.root.join('public', 'uploads', "image.jpg")
    File.open(image_path, 'wb') do |file|
      file.write(uploaded_image.read)
    end

    # Call the Python script with the image path as an argument
    python_output = `python3 python/hello_world.py #{image_path}`

    # Parse the output and save it to the @image instance
    output_lines = python_output.split("\n")
    processed_image_path = output_lines[0]
    text_output = output_lines[1]

    @image = Image.new
    @image.original_image.attach(uploaded_image)
    @image.processed_image.attach(
      io: File.open(processed_image_path),
      filename: File.basename(processed_image_path)
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
