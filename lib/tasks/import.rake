require 'json'

namespace :import do
  desc 'Load a batch of photos from a JSON file'
  task :json, [:json_file, :import_photo_root, :skip_autorotate] => :environment do |t, args|
    File.open(args.json_file) do |fh|
      json_data = JSON.parse(fh.read)
      skip_autorotate = JSON.parse(args.skip_autorotate || 'false')
      result = ::Photo::BulkImportJson.(params: {json_data: json_data, import_photo_root: args.import_photo_root, skip_autorotate: skip_autorotate})
      puts "Photo import completed: #{result.success? ? 'Successfully' : 'Failed'}: success count #{result[:success_count]} Failure count: #{result[:failure_count]}"
    end
  end
end