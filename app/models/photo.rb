class Photo < ApplicationRecord
  belongs_to :source
  has_many :photo_tags
  store :image_versions, coder: JSON
  store :metadata, coder: JSON
  store :tags, coder: JSON

end