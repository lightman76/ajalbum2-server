require "reform"
require "reform/form/dry"
require 'dry-validation'

module Photo::Contract
  class Create < Reform::Form
    include Dry
    property :user
    property :image_stream, virtual: true #must provide a stream with the image data
    property :original_file_name, virtual: true #when loading images from files, we likely won't be specifying a title, so we can fallback to the original file name
    property :original_content_type, virtual: true #If image comes from a stream, we may not be easily able to find it's content type so specify here
    property :time, virtual: true #Override for time of photo, otherwise metadata in image will be used
    property :title
    property :taken_in_tz, virtual: true #offset from GMT of localtime where picture was taken. int: minutes offset from GMT
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
    property :feature_threshold, virtual: true #discriminator to filter out lower value pictures, archive, etc.  Default to 0, negative means probably shouldn't show, positive good to great picture, highlight
    property :autorotate, virtual: true #should we auto-rotate the image based on the metadata or leave orientation as is.  Old version appears to have rotated the original images but not updated the metadata to reflect this rotation causing them to be "double rotated"

    validation name: :default do
      params do
        required(:image_stream).filled
      end
    end

  end
end
