require_relative "../contract/bulk_import_json"

class Photo::BulkImportJson < Trailblazer::Operation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::BulkImportJson)
  step Contract::Validate()
  step :process_params
  step :process_json

  def process_params(options, params:, **)
    options[:json_data] = params[:json_data]
    options[:import_photo_root] = params[:import_photo_root] #path which from_original_file_path's are relative
    options[:skip_autorotate] = params[:skip_autorotate]
    options[:success_count] = 0
    options[:failure_count] = 0
    true
  end

  def process_json(options, json_data:, **)
    json_data["photos"].each do |jp|
      from_orig_location = jp["from_original_file_path"]
      file_in = File.open(File.join(options[:import_photo_root], from_orig_location))
      parsed_date = DateTime.iso8601(jp["taken_timestamp"])

      result = ::Photo::Operation::Create.(params: {
          photo: {
              image_stream: file_in,
              original_file_name: jp["original_file_name"],
              original_content_type: jp["original_content_type"],
              time: parsed_date,
              title: jp["title"],
              taken_in_tz: jp["taken_in_tz"],
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
              autorotate: !options[:skip_autorotate]
          }
      })
      if result.success?
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
    puts "\n\nImport complete: Successful imports: #{options[:success_count]}, Failed imports: #{options[:failure_count]}\n\n\n"
    true
  end


end