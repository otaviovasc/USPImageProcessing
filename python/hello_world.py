import cv2
import sys
import os
import numpy as np
import requests
import cloudinary.uploader
import cloudinary
import tempfile
from dotenv import load_dotenv

load_dotenv()

# Get the path of the original image from the command line argument
image_path = sys.argv[1]


# Load the original image
# Download the image file
response = requests.get(image_path)
img_array = np.asarray(bytearray(response.content), dtype=np.uint8)
img = cv2.imdecode(img_array, cv2.IMREAD_GRAYSCALE)

# Apply the Otsu's thresholding method to binarize the image
_, binary_image = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

# Count image pixels
width, height = binary_image.shape
black_pixels = 0
white_pixels = 0
for y in range (height):
    for x in range (width):
        if (binary_image[x,y] == 0):
            black_pixels += 1
        else:
            white_pixels += 1
media_white = (white_pixels / (black_pixels + white_pixels)) * 100
media_black = (black_pixels / (black_pixels + white_pixels)) * 100

# Cloudinary configuration
cloud_name = os.environ['CLOUDINARY_NAME']
api_key = os.environ['CLOUDINARY_KEY']
api_secret = os.environ['CLOUDINARY_SECRET']
cloudinary.config(
    cloud_name=cloud_name,
    api_key=api_key,
    api_secret=api_secret
)

# Save the binary image to a temporary file
with tempfile.NamedTemporaryFile(suffix=".png") as tmp_file:
    cv2.imwrite(tmp_file.name, binary_image)

    # Upload the binary image file to Cloudinary
    upload_result = cloudinary.uploader.upload(tmp_file.name)

# Print the image URL and the text output to the console
print(upload_result["url"])
print(f'Pretos: {media_black:.2f}% - Brancos: {media_white:.2f}%')
