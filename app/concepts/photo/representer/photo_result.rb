require 'roar/json'
require 'roar/decorator'


module Photo::Representer
  class PhotoResult < Roar::Decorator
    include Roar::JSON

    property :id
    property :title
    property :description
    property :time_id
    property :time
    property :taken_in_tz
    property :location_latitude
    property :location_longitude
    property :location_name
    property :source_id
    property :source_name
    property :metadata
    property :tags
    property :feature_threshold
    property :image_versions
  end
end