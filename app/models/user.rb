class User < ApplicationRecord
  has_many :photos
  has_many :tags
  has_many :sources
  has_many :user_authentications
end