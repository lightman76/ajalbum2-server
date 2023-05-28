require_relative "../contract/create"
require 'fileutils'

class Photo::Operation::Create < ::BaseOperation

  step Model(Photo, :new)
  step Contract::Build(constant: ::Photo::Contract::Create)
  step Contract::Validate(key: :photo)
  #TODO: need to parse the file, populate information not overridden in model with the details from the image
  #TODO: populate the model with proper time_id
  #TODO: need to then determine the base directory for this image and stream the image into there
  # TODO: need to then generate our other image sizes
  #   thinking thumbnail at 640x640 dimensions (filling this box and cropping excess)
  #     at 60-70% compression (need to test - likely will be shrinking this in browser anyway)
  #   Probably do normal display image as 1920x1080 (or flip if portrait) probably at 80-85% compression
  #   Offer a full original res at an 80-85% compression to allow zooming
  #   Store original as-is which would be only served for a download to print
  #
  pass :initialize_warnings
  step :hydrate_user_param
  # Step 1: Save the original image to a temporary working dir so we can run operations on it
  step :temporary_persist_original_image

  #Load the image metadata
  step :load_image_metadata


  #now handle populating other "computed" fields and merging in overrides
  step :populate_time_id
  step :populate_source_id
  step :populate_feature_threshold
  step :populate_user
  step :populate_title
  step :populate_location
  step :record_metadata
  step :process_tags
  step :process_original_image
  step Contract::Persist()

  step :process_image


  step :cleanup_success
  fail :cleanup_failure
  fail :debug

  def initialize_warnings(options, model:, **)
    options[:warnings] = []
  end

  def process_image(options, model:, params:, **)
    op_thumb = ::Photo::Operation::GenerateImages::Thumbnail.(params: { photo_model: model, autorotate: params[:photo][:autorotate] })
    unless op_thumb.success?
      Rails.logger.warn("Failed to create thumbnail: #{op_thumb.errors.details.to_json}")
      options[:warnings] << "Failed to create thumbnail: #{op_thumb.errors.details.to_json}"
    end
    op_hd = ::Photo::Operation::GenerateImages::ScreenHd.(params: { photo_model: model, autorotate: params[:photo][:autorotate] })
    unless op_hd.success?
      Rails.logger.warn("Failed to create ScreenHD: #{op_hd.errors.details.to_json}")
      options[:warnings] << "Failed to create ScreenHD: #{op_hd.errors.details.to_json}"
    end
    op_full = ::Photo::Operation::GenerateImages::FullRes.(params: { photo_model: model, autorotate: params[:photo][:autorotate] })
    unless op_full.success?
      Rails.logger.warn("Failed to create FullRes: #{op_full.errors.details.to_json}")
      options[:warnings] << "Failed to create FullRes: #{op_full.errors.details.to_json}"
    end
    model.save!
    true
  end

  def process_original_image(options, model:, user:, tmp_file_path:, **)
    # first copy the tmp image to the correct subdir of the originals folder
    retry_cnt = nil
    success = false
    while (!success) do

      FileUtils.mkdir_p(File.join(PhotoUtils.originals_path, user.id.to_s, PhotoUtils.base_path_for_photo(model)))
      full_path = File.join(PhotoUtils.originals_path, user.id.to_s, PhotoUtils.base_path_for_photo(model), PhotoUtils.file_name_for_photo(model, retry_cnt: retry_cnt))
      if File.exists?(full_path)
        retry_cnt = retry_cnt.nil? ? 0 : (retry_cnt + 1)
      else
        success = true
      end
    end
    #have non-conflicting file_name, store it
    FileUtils.cp(tmp_file_path, full_path)
    #now store it in the image_versions
    model.image_versions['original'] = {
      "root_store": "originals",
      "relative_path": File.join(PhotoUtils.base_path_for_photo(model), PhotoUtils.file_name_for_photo(model, retry_cnt: retry_cnt)),
      "retry_count": retry_cnt,
      "content_type": model.metadata["original_content_type"],
      "retry_cnt": retry_cnt
    }
    Rails.logger.info("  Copied original for #{tmp_file_path} to #{full_path}")
    options[:original_file_path] = full_path
    options[:original_retry_cnt] = retry_cnt
    if retry_cnt
      model.time_id = model.time_id + (retry_cnt + 1) # this should be in milliseconds
      model.save!
    end
    true
  end

  def process_tags(options, model:, params:, user:, **)
    photo = params[:photo]
    tags = []
    if photo[:tag_ids]
      photo[:tag_ids].each do |tid|
        tag = ::Tag.get(tid)
        tags << tag if tag
      end
    end
    process_tag_type(user, 'tag', photo[:tag_names], tags) #eg nature, cute kids
    process_tag_type(user, 'people', photo[:tag_people], tags)
    process_tag_type(user, 'event', photo[:tag_events], tags, timestamp: model.time) #eg Yosemite trip
    process_tag_type(user, 'location', photo[:tag_locations], tags, lat: model.location_latitude, long: model.location_longitude) # eg Paris
    process_tag_type(user, 'album', photo[:tag_albums], tags) #this will be just the album name.  Will need a separate process to export album details and import that to add/update the tags with the additional album details
    model.tags['tags'] = tags
    #materialize these tags as photo_tags
    tags.each do |tag_id|
      model.photo_tags << PhotoTag.new(photo: model, tag_id: tag_id, time_id: model.time_id)
    end
    true
  end

  def process_tag_type(user, tag_type, names, tags, lat: nil, long: nil, timestamp: nil)
    if names
      names.uniq!
      names.each do |name|
        result = ::Tag::Operation::GetOrCreate.(params: { tag: { tag_type: tag_type, name: name, location_latitude: lat, location_longitude: long, event_date: timestamp, user: user } })
        tags << result["tag"].id if result.success?
      end
    end
  end

  def record_metadata(options, original_metadata:, model:, params:, **)
    photo = params[:photo]
    metadata = original_metadata
    metadata = metadata.merge(photo[:metadata]) if photo[:metadata]
    metadata.each_pair { |k, v| model.metadata[k] = v }

    true
  end

  def populate_location(options, params:, original_metadata:, model:, **)
    photo = params[:photo]
    latitude = convert_gps_loc(original_metadata[:gps_latitude_ref], original_metadata[:gps_latitude])
    longitude = convert_gps_loc(original_metadata[:gps_longitude_ref], original_metadata[:gps_longitude])
    latitude = photo[:location_latitude] if photo[:location_latitude]
    longitude = photo[:location_longitude] if photo[:location_longitude]
    if latitude && longitude
      model.location_latitude = latitude
      model.location_longitude = longitude
    end

    #TODO: if location_name param is null, try to match location tags to suggest location

    true
  end

  def convert_gps_loc(ref, pos_arr)
    if ref && pos_arr
      ref = ref.upcase
      val = 0
      level = 0
      pos_arr.each do |v|
        val += v.to_f / 60.pow(level)
        level += 1
      end
      return val
    end
    nil
  end

  def populate_title(options, params:, original_metadata:, **)
    photo = params[:photo]
    if photo[:original_file_name]
      photo[:title] = photo[:original_file_name] unless photo[:title] #fall back to using the file name as the title
      original_metadata[:original_file_name] = photo[:original_file_name] #store the original file name in the metadata.  If run into problems, that may help debug
    end
    if photo[:original_content_type]
      original_metadata[:original_content_type] = photo[:original_content_type] #store the content type of the original as this may be transformed in the generated images
    end
    unless original_metadata[:original_content_type]
      #should probably try to guess based on file name if we've got it or else look at header bytes on the file itself...
      if photo[:original_file_name] && (/.jpg/i.match(photo[:original_file_name]) || /.jpeg/i.match(photo[:original_file_name]))
        original_metadata[:original_content_type] = photo[:original_content_type] = "image/jpeg"
      end
    end
    true
  end

  def populate_user(options, model:, user:, **)
    model.user = user
    true
  end

  def temporary_persist_original_image(options, params:, user:, **)
    photo = params[:photo]
    tmp_dir = PhotoUtils.temporary_upload_dir(user.id)
    FileUtils.mkdir_p(tmp_dir)
    tmp_file_path = File.join(tmp_dir, "upload_#{Process.pid}_#{Time.now.to_i}.jpg")
    File.open(tmp_file_path, 'w') do |fh|
      IO.copy_stream(photo[:image_stream], fh)
      fh.flush
      fh.close
    end

    options[:tmp_file_path] = tmp_file_path
    true
  end

  def load_image_metadata(options, tmp_file_path:, **)
    #TODO: this is jpg specific, may want to separate this logic to another operation which can dispatch based on content type

    #Goal here is to attempt to extract a set of known metadata that we want from the images
    # ifd0:
    #   Timestamp Ruby Date from (date_time)
    #   Device Name (make + model)
    #   orientation
    #      1= 0 degrees: the correct orientation, no adjustment is required.
    #      2= 0 degrees, mirrored: image has been flipped back-to-front.
    #      3= 180 degrees: image is upside down.
    #      4= 180 degrees, mirrored: image is upside down and flipped back-to-front.
    #      5= 90 degrees: image is on its side.
    #      6= 90 degrees, mirrored: image is on its side and flipped back-to-front.
    #      7= 270 degrees: image is on its far side.
    #      8= 270 degrees, mirrored: image is on its far side and flipped back-to-front.
    # gps:
    #   gps_timestamp Ruby Date from (gps_date_stamp, gps_time_stamp)
    #   gps_latitude_ref
    #   gps_latitude
    #   gps_longitude_ref
    #   gps_longitude
    #   gps_map_datum
    #   gps_altitude_ref
    #   gps_altitude
    # exif:
    #   exposure_time
    #   fnumber
    #   iso_speed_ratings
    #   shutter_speed_value
    #   aperture_value
    #   brightness_value
    #   metering_mode
    #   flash
    #   focal_length
    #   color_space
    #   pixel_x_dimension
    #   pixel_y_dimension
    #   exposure_mode
    #   white_balance
    #   focal_length_in_35mm_film
    # Synthetic: will populate this elsewhere from the import process
    #   original_file_name
    #   original_content_type
    begin
      exif_data = Exif::Data.new(IO.read(tmp_file_path))
    rescue
      # seems we're getting errors for some of the older scanned images (at least those, maybe others, but haven't tried yet), so just ignore these errors
      Rails.logger.warn("    Failed to extract EXIF metadata from #{tmp_file_path}")
    end

    metadata = {}

    data_gps = nil
    data_gps = exif_data[:gps] if exif_data && exif_data[:gps]
    if data_gps
      metadata[:gps_timestamp] = gps_date_parse(data_gps[:gps_date_stamp], data_gps[:gps_time_stamp])
      metadata[:gps_latitude_ref] = data_gps[:gps_latitude_ref]
      metadata[:gps_latitude] = data_gps[:gps_latitude]
      metadata[:gps_longitude_ref] = data_gps[:gps_longitude_ref]
      metadata[:gps_longitude] = data_gps[:gps_longitude]
      metadata[:gps_altitude_ref] = data_gps[:gps_altitude_ref]
      metadata[:gps_altitude] = data_gps[:gps_altitude]
      metadata[:gps_map_datum] = data_gps[:gps_map_datum]
    end

    data_ifd0 = nil
    data_ifd0 = exif_data[:ifd0] if exif_data && exif_data[:ifd0]
    if data_ifd0
      metadata[:date_time], metadata[:date_time_zone] = parse_exif_timestamp(data_ifd0[:time_stamp], metadata[:gps_timestamp])
      metadata[:date_time], metadata[:date_time_zone] = parse_exif_timestamp(data_ifd0[:date_time], metadata[:gps_timestamp]) unless metadata[:date_time]
      metadata[:device_name] = "#{data_ifd0[:make]} #{data_ifd0[:model]}".strip
      metadata[:orientation] = data_ifd0[:orientation]
    end

    exif = nil
    exif = exif_data[:exif] if exif_data && exif_data[:exif]
    if exif
      metadata[:exposure_time] = exif[:exposure_time]
      metadata[:fnumber] = exif[:fnumber]
      metadata[:iso_speed_ratings] = exif[:iso_speed_ratings]
      metadata[:shutter_speed_value] = exif[:shutter_speed_value]
      metadata[:aperture_value] = exif[:aperture_value]
      metadata[:brightness_value] = exif[:brightness_value]
      metadata[:metering_mode] = exif[:metering_mode]
      metadata[:flash] = exif[:flash]
      metadata[:focal_length] = exif[:focal_length]
      metadata[:color_space] = exif[:color_space]
      metadata[:pixel_x_dimension] = exif[:pixel_x_dimension]
      metadata[:pixel_y_dimension] = exif[:pixel_y_dimension]
      metadata[:exposure_mode] = exif[:exposure_mode]
      metadata[:white_balance] = exif[:white_balance]
      metadata[:focal_length_in_35mm_film] = exif[:focal_length_in_35mm_film]
    end

    options[:original_metadata] = metadata
    true
  end

  def gps_date_parse(date, time)
    date_str = "#{date.gsub(":", "-")}T#{sprintf("%02d:%02d:%02.3f", time[0], time[1], time[2])}Z"
    DateTime.iso8601(date_str)
  rescue
    return nil
  end

  def parse_exif_timestamp(exif_datetime, gps_timestamp = nil)
    if exif_datetime
      exif_date, exif_time = exif_datetime.split(" ")
      exif_date = exif_date.gsub(":", "-")
      timezone_offset_str = APP_CONFIG["defaults"]["timezone_offset_str"]
      #see if we can determine the correct zone offset based on the gps_timestamp when available
      if gps_timestamp
        diff_hour = (gps_timestamp.hour - exif_time.split(":")[0].to_i) % 24
        diff_min = ((1.0 * gps_timestamp.minute - exif_time.split(":")[1].to_i) / 30).round * 30
        if diff_min < -30 || diff_min > 30
          diff_hour += diff_min / (diff_min.abs) # round up to the hour and account for this in the diff_hour
          diff_min = 0
        end
        timezone_offset_str = sprintf("%3d:%2d", diff_hour, diff_min).sub(/^0/, "+")
      end
      return [DateTime.iso8601("#{exif_date}T#{exif_time}#{timezone_offset_str}"), timezone_offset_str]
    end
    nil
  end

  def populate_source_id(options, params:, model:, user:, **)
    photo = params[:photo]
    #TODO: default this to coming from metadata and overriding with this parameter
    raw_name = photo[:source_name]
    raw_name = 'unknown' unless raw_name
    src = Source.where(raw_name: raw_name).first
    if src
      model.source_name = src.display_name
      model.source_id = src.id
    else
      #default the display name to the raw name.  Can allow users to alter these to more friendly names later
      op = ::Source::Create.(params: { raw_name: raw_name, display_name: raw_name, user: user })
      src = op[:model]
      model.source_name = src.display_name
      model.source_id = src.id
    end
    true
  end

  def populate_feature_threshold(options, params:, model:, **)
    params[:photo][:feature_threshold] = 0 if params[:photo][:feature_threshold].nil?
    model.feature_threshold = params[:photo][:feature_threshold]
    true
  end

  def populate_time_id(options, params:, original_metadata:, model:, **)
    photo = params[:photo]
    #TODO: read this from image metadata as the default time, then if overridden, use that
    time = original_metadata[:date_time]
    #if it doesn't have date_time, probably won't have a GPS time, but what the heck, check anyway
    if !time && original_metadata[:gps_timestamp]
      time = original_metadata[:gps_timestamp] + APP_CONFIG["defaults"]["timezone_offset"].minutes #adjust the GPS timestamp back to the default timezone
    end

    time = photo[:time] if photo[:time] #if time metadata overridden
    if time
      options[:time] = time
      model.time = time
      model.time_id = time.to_i * 1000 # this should be in milliseconds
      model.taken_in_tz = photo[:taken_in_tz] || (original_metadata[:date_time_zone] ? original_metadata[:date_time_zone].to_f * 60 : nil) || APP_CONFIG["defaults"]["timezone_offset"]

      # Now assign the date bucket that will be used for the photo - take the time + the difference in the timezone it was taken in and the current timezone
      # Trying to get to the time in the location the photo was taken and using that date as a consistent date (ignoring time zones, DST changes, etc)
      date_bucket_d = time.dup + (model.taken_in_tz - APP_CONFIG["defaults"]["timezone_offset"]).minutes
      model.date_bucket = photo[:date_bucket] = date_bucket_d.in_time_zone(ActiveSupport::TimeZone.new(model.taken_in_tz * 60)).strftime("%Y%m%d").to_i
      return true
    end
    add_error(options, :messages, "Could not determine timestamp for photo #{photo[:original_file_name]}")
    return false #must have a time id of some sort set for the image...  TODO: Could add an automatic timestamp.  Use a really old date range and find the max time in that range and then add one to the time ID
  end

  def cleanup_success(options, params:, **)
    cleanup(options)
    true
  end

  def cleanup_failure(options, params:, **)
    cleanup(options)
    true
  end

  def cleanup(options)
    if options[:tmp_file_path]
      File.delete(options[:tmp_file_path])
    end
    true
  end

  def debug(options, params:, **)
    binding.pry
    true
  end

end
