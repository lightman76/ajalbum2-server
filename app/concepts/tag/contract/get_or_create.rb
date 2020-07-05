require "reform"


module Tag::Contract
  class GetOrCreate < Reform::Form
    property :tag_type
    property :name
    property :location_latitude
    property :location_longitude
    property :event_date

    validation do
      required(:tag_type).filled #TODO: validate tag type is recognized
      required(:name).filled
    end

  end
end
