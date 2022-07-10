require "reform"


module Tag::Contract
  class GetOrCreate < Reform::Form
    property :authorization, virtual: true #only when used in the endpoint configuration
    property :tag_type
    property :user
    property :name
    property :description
    property :shortcut_url
    property :location_latitude
    property :location_longitude
    property :event_date

    validation name: :default do
      params do
        required(:tag_type).filled #TODO: validate tag type is recognized
        required(:name).filled
        required(:user).filled
      end
    end

  end
end
