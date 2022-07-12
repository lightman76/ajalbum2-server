class Tag < ApplicationRecord
  VALID_TAG_TYPES = [:tag, :location, :people, :event, :album, :species]
  belongs_to :user
  has_many :photo_tags
end