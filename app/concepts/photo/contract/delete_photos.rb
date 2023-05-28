require "reform"

class Photo::Contract::DeletePhotos < Reform::Form
  property :authorization
  property :user # This is the user whose photos will be edited (only if the authorization allows)
  property :photo_time_ids # array to allow bulk editing

  validation name: :default do
    params do
      required(:authorization).filled
      required(:user).filled
      required(:photo_time_ids).filled
    end
  end

end
