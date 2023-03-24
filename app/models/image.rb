class Image < ApplicationRecord
  has_one_attached :original_image
  has_one_attached :processed_image
end
