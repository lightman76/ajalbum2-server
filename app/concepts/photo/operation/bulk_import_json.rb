require_relative "../contract/bulk_import_json"

class Photo::Operation::BulkImportJson < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::BulkImportJson)
  step Contract::Validate()
  step :process_params
  step :sync_to_model
  step :hydrate_user
  step :process_json

  def process_params(options, params:, **)
    options[:json_data] = params[:json_data]
    options[:import_photo_root] = params[:import_photo_root] #path which from_original_file_path's are relative
    options[:skip_autorotate] = params[:skip_autorotate]
    options[:success_count] = 0
    options[:failure_count] = 0
    true
  end

  def process_json(options, json_data:, user:, **)

    processing_pool = ::Concurrent::FixedThreadPool.new(APP_CONFIG["processing_concurrency"] || 6, auto_terminate: false, name: "Image Processing")
    futures = []

    json_data["photos"].each do |jp|
      from_orig_location = jp["from_original_file_path"]
      full_path_file = File.join(options[:import_photo_root], from_orig_location)
      puts "Bulk Import from file #{full_path_file} - exists? #{File.exist?(full_path_file)}"
      file_in = File.open(full_path_file)
      parsed_date = DateTime.iso8601(jp["taken_timestamp"])

      jp["taken_in_tz"] = "-05:00" unless jp["taken_in_tz"]
      tz_offset_parts = jp["taken_in_tz"].split(":")
      tz_offset_min = (tz_offset_parts[0].to_i * 60) + (tz_offset_parts[1].to_i) if tz_offset_parts

      result = ::Photo::Operation::Create.(params: {
        photo: {
          user: user,
          image_stream: file_in,
          original_file_name: jp["original_file_name"],
          original_content_type: jp["original_content_type"],
          time: parsed_date,
          title: jp["title"],
          taken_in_tz: tz_offset_min,
          location_latitude: jp["location_latitude"],
          location_longitude: jp["location_longitude"],
          location_name: jp["location_name"],
          source_name: jp["source_name"],
          description: jp["description"],
          tag_names: jp["tag_names"],
          tag_people: jp["tag_people"],
          tag_events: jp["tag_events"],
          tag_locations: jp["tag_locations"],
          tag_albums: jp["tag_albums"],
          feature_threshold: jp["feature_threshold"],
          autorotate: !options[:skip_autorotate],
          processing_pool: processing_pool,
        }
      })
      if result.success?
        futures << op[:processing_future]
        options[:success_count] += 1
        puts "   Successfully imported #{parsed_date.to_s} - #{jp["title"]}"
      else
        options[:failure_count] += 1
        puts "!! Failed to import #{parsed_date.to_s} - #{jp["title"]} from #{from_orig_location}"
      end
    rescue StandardError => e
      options[:failure_count] += 1
      puts "!! Failed to import #{parsed_date.to_s} - #{jp["title"]} from #{from_orig_location}: #{e.message}\n#{e.backtrace}"
    ensure
      file_in.close if file_in
    end
    puts "\n\nWaiting for image processing to complete..."
    is_complete = false
    while !is_complete do
      status = futures.inject({ failed: 0, success: 0, pending: 0 }) do |c, v|
        key = v.complete? ? (v.rejected? ? :failed : :success) : :pending
        c[key] = c[key] + 1
        c
      end
      is_complete = status[:pending] == 0
      puts "  #{status[:pending]} pending; #{status[:success]} completed; #{status[:failed]} errors"
      sleep(3) unless is_complete
    end
    processing_pool.shutdown

    puts "\n\nImport complete: Successful imports: #{options[:success_count]}, Failed imports: #{options[:failure_count]}\n\n\n"
    true
  end


end
