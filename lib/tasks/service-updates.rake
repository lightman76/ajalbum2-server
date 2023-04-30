namespace :service_update do
  desc 'Add date_bucket to photos'
  task :populate_date_bucket, [] => :environment do |t, args|
    cnt = 0
    Photo.where(date_bucket: nil).find_each do |photo|
      date_bucket_d = photo.time.dup + (photo.taken_in_tz - APP_CONFIG["defaults"]["timezone_offset"]).minutes
      photo.date_bucket = date_bucket_d.in_time_zone(ActiveSupport::TimeZone.new(photo.taken_in_tz * 60)).strftime("%Y%m%d").to_i
      photo.save!
      cnt += 1
      puts "  Updated #{cnt}" if cnt % 10 == 0
    end
    puts "Completed update of #{cnt} photos"
  end
end
