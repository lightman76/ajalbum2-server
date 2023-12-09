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

    processing_pool = ::Concurrent::FixedThreadPool.new(APP_CONFIG["processing_concurrency"] || 6, auto_terminate: false, name: "Image Processing", max_queue: 10)
    futures = []

    model.file_list.each do |file_path|
      if File.exists?(file_path)
        begin
          file_in = File.open(file_path)

          content_type = "image/jpeg"
          content_type = "image/png" if /.png$/i.match(file_path)
          # TODO: Add other types as needed

          puts "  Processing #{file_path} at #{DateTime.now} - autorotate=#{model.autorotate}"
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
              feature_threshold: model.feature_threshold,
              autorotate: model.autorotate,
              processing_pool: processing_pool,
            }
          })

          if op.success?
            future = op[:processing_future]
            futures << future
            obs = Object.new

            def obs.path(path)
              @path = path
            end

            def obs.op(path)
              @op = op
            end

            def obs.update(time, value, reason)
              puts "Observer called with #{time}; #{value}; #{reason}"
              if value
                if @op[:warnings] && @op[:warnings].length > 0
                  puts "    Errors while importing #{@path}: #{@op[:warnings].to_json}"
                else
                  puts "    Successfully imported #{@path}"
                end
              else
                puts "  !!Failed to import #{@path};; #{reason} ;; #{::BaseOperation.human_string_from_op_errors(@op)}"
              end
            end

            future.add_observer(obs)

            puts "    Successfully started processing #{file_path}"
            success_count += 1
          else
            puts "  !!Failed to import #{file_path} #{::BaseOperation.human_string_from_op_errors(op)}"
            error_count += 1
          end
        rescue StandardError => e
          puts "Could not find file #{file_path} - skipping: #{e.message}"
          puts "  !!Failed to import #{file_path} #{::BaseOperation.human_string_from_op_errors(op)}"
          error_count += 1
        end
      else
        puts "Could not find file #{file_path} - skipping"
        error_count += 1
      end
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

    options[:success_count] = success_count
    options[:error_count] = error_count
    puts "\nProcessing completed: #{error_count} errors and #{success_count} successes."
    true
  end

end

