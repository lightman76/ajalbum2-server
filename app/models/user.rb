class User < ApplicationRecord
  has_many :photos
  has_many :tags
  has_many :sources
end