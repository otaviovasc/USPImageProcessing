import cv2
import sys
import os


# Get the path of the original image from the command line argument
image_path = sys.argv[1]

# Load the original image
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

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

# Get the directory and filename of the input image
image_dir, image_filename = os.path.split(image_path)

# Generate the path for the processed image
processed_image_filename = f'{os.path.splitext(image_filename)[0]}_processed.jpg'
processed_image_path = os.path.join(image_dir, processed_image_filename)

# Save the processed image to disk
cv2.imwrite(processed_image_path, binary_image)

# Print the path of the processed image and the text output to the console
print(processed_image_path)
print(f'Pretos: {media_black:.2f}% - Brancos: {media_white:.2f}%')
