#Begin Preinitialize
require 'yaml'
require 'fileutils'

# load the base application config file
path = File.expand_path('../../environment.yml', __FILE__)
APP_CONFIG = YAML.load_file(path) unless defined? APP_CONFIG #seem to get a double load of this file in the command line cron scripts...

# load and merge in the environment-specific application config info
# if present, overriding base config parameters as specified
path = File.expand_path("../../environments/#{ENV['RAILS_ENV']}.yml", __FILE__)
if File.exists?(path) && (env_config = YAML.load_file(path))
  APP_CONFIG.merge!(env_config)
end

# DO it here so that we can reference the user specific properties in the other config files
path = File.expand_path('../../server_specific_config.yml', __FILE__)
if File.exists?(path) && (user_config = YAML.load_file(path))
  APP_CONFIG.merge!(user_config)
end

APP_CONFIG["photo_storage"] = {} unless APP_CONFIG["photo_storage"]
APP_CONFIG["photo_storage"]["root_path"] = "/tmp/ajalbum-root" unless APP_CONFIG["photo_storage"]["root_path"]
APP_CONFIG["photo_storage"]["tmp_upload_path"] = File.join(APP_CONFIG['photo_storage']['root_path'], 'tmp_upload') unless APP_CONFIG["photo_storage"]["tmp_upload_path"]
APP_CONFIG["photo_storage"]["originals_path"] = File.join(APP_CONFIG["photo_storage"]["root_path"], "originals") unless APP_CONFIG["photo_storage"]["originals_path"]
APP_CONFIG["photo_storage"]["generated_images_path"] = File.join(APP_CONFIG["photo_storage"]["root_path"], "generated") unless APP_CONFIG["photo_storage"]["generated_images_path"]
#ensure these directories exist
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["root_path"])
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["tmp_upload_path"])
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["originals_path"])
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["generated_images_path"])


APP_CONFIG["defaults"] = {} unless APP_CONFIG["defaults"]
# default to the current timezone.  For normal cameras, we probably set its to our local timezone.
# For phone cameras, they'll probably update timezones according to their location, but should also
# have GPS data to give us a correct timezone when parsing the EXIF headers
cur_zone_offset_sec = Time.zone_offset(Time.now.getlocal.zone)
cur_zone_offset_str = sprintf("%03d:%02d", cur_zone_offset_sec / 60 / 60, cur_zone_offset_sec / 60 % 60).sub(/^0/, '+')
APP_CONFIG["defaults"]["timezone_offset_str"] = cur_zone_offset_str unless APP_CONFIG["defaults"]["timezone_offset_str"]
zone_offset_hour, zone_offset_min = APP_CONFIG["defaults"]["timezone_offset_str"].split(':')
zone_offset_hour = zone_offset_hour.to_i
zone_offset_min = zone_offset_min.to_i
APP_CONFIG["defaults"]["timezone_offset"] = zone_offset_hour * 60 + (zone_offset_hour / (zone_offset_hour.abs)) * zone_offset_min

