require "reform"
require "reform/form/dry"


module Photo::Contract
  class Create < Reform::Form
    include Dry

    property :image_stream, virtual: true #must provide a stream with the image data
    property :time, virtual: true #Override for time of photo, otherwise metadata in image will be used
    property :title
    property :taken_in_tz #offset from GMT of localtime where picture was taken
    property :latitude, virtual: true
    property :longitude, virtual: true
    property :location_name
    property :source_name, virtual: true #override metadata's indiciation of source, if available.
    property :description
    property :metadata #metadata override, otherwise will be picked up from image
    property :tags #array of tag ids
    property :feature_threshold #discriminator to filter out lower value pictures, archive, etc.  Default to 0, negative means probably shouldn't show, positive good to great picture, highlight

    validation do
      required(:image_stream).filled
    end

  end
end
