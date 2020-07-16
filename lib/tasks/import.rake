require 'json'

namespace :import do
  desc 'Load a batch of photos from a JSON file'
  task :json, [:json_file, :import_photo_root] => :environment do |t, args|
    File.open(args.json_file) do |fh|
      json_data = JSON.parse(fh.read)
      result = ::Photo::BulkImportJson.(params: {json_data: json_data, import_photo_root: args.import_photo_root})
      puts "Photo import completed: #{result.success? ? 'Successfully' : 'Failed'}: success count #{result[:success_count]} Failure count: #{result[:failure_count]}"
    end
  end
end