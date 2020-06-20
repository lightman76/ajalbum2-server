class CreatePhotos < ActiveRecord::Migration[6.0]
  def up
    execute("create table photos(id bigint primary key, title varchar(1024), time_id bigint not null, time timestamp null default null, taken_in_tz int null default null, created_at timestamp null default null, updated_at timestamp null default null, img_base_path varchar(256), location_latitude double null default null, location_longitude double null default null, location_name varchar(1024), source_id bigint not null, source_name varchar(255) null default null, description mediumtext, metadata JSON, tags JSON, feature_threshold int, image_versions JSON)")
    execute("create fulltext index photos_fulltext on photos(title, description, location_name)")
    execute("create index photos_time_id on photos(time_id desc, feature_threshold desc)")
    execute("create index photos_time on photos(time desc,feature_threshold desc)")
    execute("create index photos_loc_gis on photos(location_longitude, location_latitude, time_id, feature_threshold desc)")
  end
  def down
    execute("drop table photos")
  end
end
