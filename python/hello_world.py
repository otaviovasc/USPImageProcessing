import numpy as np
import sys
import cv2
import requests
import base64

# load_dotenv()

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

# Save the binary image to a temporary file
retval, image = cv2.imencode('.png', binary_image)
base64_encoded_data = base64.b64encode(image)
base64_message = base64_encoded_data.decode('utf-8')

print(base64_message)
print(f'Pretos: {media_black:.2f}% - Brancos: {media_white:.2f}%')
