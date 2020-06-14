require_relative "../contract/create"

class Photo::Create < Trailblazer::Operation
  step Model(Photo, :new)
  step Contract::Build(constant: ::Photo::Contract::Create)
  step Contract::Validate(key: :photo)
  step :populate_time_id
  step :populate_source_id

  #TODO: need to parse the file, populate information not overridden in model with the details from the image
  #TODO: populate the model with proper time_id
  #TODO: need to then determine the base directory for this image and stream the image into there
  # TODO: need to then generate our other image sizes
  #   thinking thumbnail at 640x640 dimensions (filling this box and cropping excess)
  #     at 60-70% compression (need to test - likely will be shrinking this in browser anyway)
  #   Probably do normal display image as 1920x1080 (or flip if portrait) probably at 80-85% compression
  #   Offer a full original res at an 80-85% compression to allow zooming
  #   Store original as-is which would be only served for a download to print
  step Contract::Persist()
  fail :debug

  def populate_source_id(options, params:, **)
    #TODO: default this to coming from metadata and overriding with this parameter
    raw_name = params[:photo][:source_name]
    raw_name = 'unknown' unless raw_name
    src = Source.where(raw_name: raw_name).first
    if src
      options[:model][:source_name] = src.display_name
      options[:model][:source_id] = src.id
    else
      #default the display name to the raw name.  Can allow users to alter these to more friendly names later
      op = ::Source::Create.(params: {source: {raw_name: raw_name, display_name: raw_name}})
      src = op[:model]
      options[:model][:source_name] = src.display_name
      options[:model][:source_id] = src.id
    end
    true
  end

  def populate_time_id(options, params:, **)
    #TODO: read this from image metadata as the default time, then if overridden, use that
    time = params[:photo][:time]
    if time
      options[:model][:time] = time
      options[:model][:time_id] = time.to_i
    end
    true
  end

  def debug(options, params:, **)
    binding.pry
    true
  end

end