class Photo::Operation::BulkLoadFromDisk < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::BulkLoadFromDisk)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user

  step :process_files

  def process_files(options, model:, user:, **)
    error_count = 0
    success_count = 0

    model.file_list.each do |file_path|
      if File.exists?(file_path)
        file_in = File.open(file_path)

        content_type = "image/jpeg"
        content_type = "image/png" if /.png$/i.match(file_path)
        #TODO: Add other types as needed

        puts "  Processing #{file_path} at #{DateTime.now}"
        op = ::Photo::Operation::Create.(params: {
          photo: {
            user: user,
            image_stream: file_in,
            original_file_name: File.basename(file_path),
            original_content_type: content_type,
            title: File.basename(file_path),
            tag_names: model.general_tags,
            tag_events: model.event_tags,
            tag_locations: model.location_tags,
            tag_albums: model.album_tags,
            feature_threshold: model.feature_threshold
          }
        })

        if op.success?
          success_count += 1
          puts "    Successfully imported #{file_path}"
        else
          puts "  !!Failed to import #{file_path} #{human_string_from_op_errors(op)}"
          error_count += 1
        end
      else
        puts "Could not find file #{file} - skipping"
        error_count += 1
      end
    end
    options[:success_count] = success_count
    options[:error_count] = error_count
    puts "\nProcessing completed: #{error_count} errors and #{success_count} successes."
    true
  end

end

