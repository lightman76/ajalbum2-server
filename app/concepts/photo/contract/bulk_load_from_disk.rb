require "reform"

class Photo::Contract::BulkLoadFromDisk < Reform::Form
  property :user
  property :file_list
  property :location_tags
  property :event_tags
  property :general_tags
  property :album_tags
  property :feature_threshold

  validation name: :default do
    params do
      required(:user).filled
      required(:file_list).filled
    end
  end

end

