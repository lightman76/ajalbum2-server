require "reform"

class Photo::Contract::EditPhotoDetails < Reform::Form
  property :authorization
  property :user #This is the user whose photos will be edited (only if the authorization allows)
  property :photo_time_ids #array to allow bulk editing

  #The following fields will be updated if present and not null
  property :updated_title
  property :updated_description
  property :updated_timestamp #TODO: will implement in the future
  property :updated_feature_threshold
  property :forced_rotation

  #List of tag IDs to add to all photos
  property :add_tags

  #List of tag IDs to remove from all photos (if present)
  property :remove_tags

  validation name: :default do
    params do
      required(:authorization).filled
      required(:user).filled
      required(:photo_time_ids).filled
    end
  end

end
