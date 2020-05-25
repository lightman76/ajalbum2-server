class CreatePhotos < ActiveRecord::Migration[6.0]
  def up
    execute("create table photos(id bigint primary key, title varchar(1024), time_id bigint not null, time timestamp null default null, taken_in_tz int null default null, created_at timestamp null default null, updated_at timestamp null default null, location_gis POINT, location_name varchar(1024), source_id bigint not null, source_name varchar(255) null default null, description mediumtext, metadata JSON, tags JSON, feature_threshold int)")
    execute("create fulltext index photos_fulltext on photos(title, description, location_name)")
    execute("create index photos_time_id on photos(time_id desc, feature_threshold desc)")
    execute("create index photos_time on photos(time desc,feature_threshold desc)")
  end
  def down
    execute("drop table photos")
  end
end
