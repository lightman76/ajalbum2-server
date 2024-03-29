require 'json'

namespace :import do
  desc 'Load a batch of photos from a JSON file'
=begin
Example call
rake import:json[andy,/new-photos/1976-1990.json,/new-photos/,true]
=end
  task :json, [:user_name, :json_file, :import_photo_root, :skip_autorotate] => :environment do |t, args|
    File.open(args.json_file) do |fh|
      unless args.user_name
        puts "Must specify a user_name to import as"
        raise "Missing user name"
      end
      user = User.where(user_name: args.user_name).first
      unless user
        puts "Could not find user for #{args.user_name}"
        raise "Could not find user"
      end

      json_data = JSON.parse(fh.read)
      skip_autorotate = JSON.parse(args.skip_autorotate || 'false')
      result = ::Photo::Operation::BulkImportJson.(params: { user: user, json_data: json_data, import_photo_root: args.import_photo_root, skip_autorotate: skip_autorotate })

      puts result["contract.default"].errors.to_json unless result.success?
      puts "Photo import completed: #{result.success? ? 'Successfully' : 'Failed'}: success count #{result[:success_count]} Failure count: #{result[:failure_count]}"
    end
  end
end