require "reform"
require "reform/form/dry"


module Photo::Contract
  class Create < Reform::Form
    include Dry

    property :image_stream, virtual: true #must provide a stream with the image data
    property :original_file_name, virtual: true #when loading images from files, we likely won't be specifying a title, so we can fallback to the original file name
    property :time, virtual: true #Override for time of photo, otherwise metadata in image will be used
    property :title
    property :taken_in_tz, virtual: true #offset from GMT of localtime where picture was taken
    property :location_latitude, virtual: true
    property :location_longitude, virtual: true
    property :location_name
    property :source_name, virtual: true #override metadata's indication of source, if available.
    property :description
    property :metadata #metadata override, otherwise will be picked up from image
    property :tag_ids, virtual: true #array of tag ids
    property :tag_names, virtual: true #array of tag names - primarily for legacy migration
    property :tag_people, virtual: true #array of names of people in photo - primarily for legacy migration
    property :tag_events, virtual: true #array of event tags - primarily for legacy migration
    property :tag_locations, virtual: true #array of location tags - primarily for legacy migration
    property :feature_threshold, default: 0 #discriminator to filter out lower value pictures, archive, etc.  Default to 0, negative means probably shouldn't show, positive good to great picture, highlight

    validation do
      required(:image_stream).filled
    end

  end
end
