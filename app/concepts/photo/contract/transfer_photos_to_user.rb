require "reform"

class Photo::Contract::TransferPhotosToUser < Reform::Form
  property :user # This is the from user
  property :authorization # this is the from user
  property :to_user
  property :to_user_authorization
  property :photo_time_ids # array to allow bulk editing

  validation name: :default do
    params do
      required(:user).filled
      required(:authorization).filled

      required(:to_user).filled
      required(:to_user_authorization).filled

      required(:photo_time_ids).filled
    end
  end

end
