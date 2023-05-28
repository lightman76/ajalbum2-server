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
file = File.read(path)
processed_erb = ERB.new(file).result
if File.exists?(path) && (user_config = YAML.load(processed_erb))
  APP_CONFIG.merge!(user_config)
end

APP_CONFIG["photo_storage"] = {} unless APP_CONFIG["photo_storage"]
APP_CONFIG["photo_storage"]["root_path"] = "/tmp/ajalbum-root" unless APP_CONFIG["photo_storage"]["root_path"]
APP_CONFIG["photo_storage"]["tmp_upload_path"] = File.join(APP_CONFIG['photo_storage']['root_path'], 'tmp_upload') unless APP_CONFIG["photo_storage"]["tmp_upload_path"]
APP_CONFIG["photo_storage"]["originals_path"] = File.join(APP_CONFIG["photo_storage"]["root_path"], "@@USER_ID@@", "originals") unless APP_CONFIG["photo_storage"]["originals_path"]
APP_CONFIG["photo_storage"]["generated_images_path"] = File.join(APP_CONFIG["photo_storage"]["root_path"], "@@USER_ID@@", "generated") unless APP_CONFIG["photo_storage"]["generated_images_path"]
# ensure these directories exist
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["root_path"])
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["tmp_upload_path"])
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["originals_path"])
FileUtils.mkdir_p(APP_CONFIG["photo_storage"]["generated_images_path"])

APP_CONFIG["jwt"] = {} unless APP_CONFIG["jwt"]
APP_CONFIG["jwt"]["keys"] = {} unless APP_CONFIG["jwt"]["keys"]
# https://stackoverflow.com/questions/33960565/how-to-generate-a-hs512-secret-key-to-use-with-jwt
APP_CONFIG["jwt"]["keys"]["auth-hmac512"] = 'xy8qOZJe/F+/t8CjnoNQqbnSADWMG3+RbuO8nPhT6NmBlafjiZVyp61Ij3WCM5tR1jj4/NcA6f4EMcrgVnP9WZ+htKikNxLkR7CyN6Ie+df2uV1CgbVpsXaAKJWK64kGqdAwBxR/oqYXoXLQ7fI2hWoUkCrH7qjFRj6ZMcyB//gTmogCMrZ+3EIiOc3C3QsdcjbGyG0saNTlZppM1DJbX+1wZyknBGOSploNHg==' unless APP_CONFIG["jwt"]["keys"]["auth-hmac512"]

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
# Automatic method - suffers from issue with daylight savings as this offset changes depending on when the server is started :(
# APP_CONFIG["defaults"]["timezone_offset"] = zone_offset_hour * 60 + (zone_offset_hour.abs != 0 ? (zone_offset_hour / (zone_offset_hour.abs)) * zone_offset_min : 0)
# So best just to hard code your offset and run with it.
APP_CONFIG["defaults"]["timezone_offset"] = -360

if APP_CONFIG["alternate_host1"]
  Rails.configuration.hosts << APP_CONFIG["alternate_host1"]
end