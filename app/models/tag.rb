class Tag < ApplicationRecord
  VALID_TAG_TYPES = [:tag, :location, :people, :event]
  has_many :photo_tags
end