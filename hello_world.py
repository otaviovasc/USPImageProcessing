import cv2
import sys

# Get the input and output file paths from the command-line arguments
input_file_path = sys.argv[1]
output_file_path = sys.argv[2]

# Load the input image
img = cv2.imread(input_file_path, cv2.IMREAD_GRAYSCALE)

# Apply Otsu thresholding
threshold_value, thresholded_image = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

# Save the thresholded image
cv2.imwrite(output_file_path, thresholded_image)
