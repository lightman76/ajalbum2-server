class AddUsersTable < ActiveRecord::Migration[6.0]
  def up
    execute("create table users (id bigint primary key, user_name varchar(64) not null)")
    execute("create unique index users_username on users(user_name)")

    execute("alter table photos add column user_id bigint not null default 0 after id")

    execute("drop index photos_time_id on photos")
    execute("drop index photos_time on photos")
    execute("drop index photos_loc_gis on photos")

    execute("create index photos_time_id on photos(user_id, time_id desc, feature_threshold desc)")
    execute("create index photos_time on photos(user_id, time desc,feature_threshold desc)")
    execute("create index photos_loc_gis on photos(user_id, location_longitude, location_latitude, time_id, feature_threshold desc)")

    execute("alter table tags add column user_id bigint not null default 0 after id")
    execute("drop index tag_type_name on tags")
    execute("drop index tag_type_gis on tags")
    execute("drop index tag_type_event_date on tags")
    execute("create index tag_type_name on tags(user_id,tag_type,name)")
    execute("create index tag_type_gis on tags(user_id,tag_type,location_longitude, location_latitude)")
    execute("create index tag_type_event_date on tags(user_id,tag_type, event_date, name)")

    execute("alter table sources add column user_id bigint not null default 0")
  end

  def down
    execute("alter table sources drop column user_id")

    execute("drop index tag_type_name on tags")
    execute("drop index tag_type_gis on tags")
    execute("drop index tag_type_event_date on tags")
    execute("create index tag_type_name on tags(tag_type,name)")
    execute("create index tag_type_gis on tags(tag_type,location_longitude, location_latitude)")
    execute("create index tag_type_event_date on tags(tag_type, event_date, name)")
    execute("alter table tags drop column user_id")

    execute("drop index photos_time_id on photos")
    execute("drop index photos_time on photos")
    execute("drop index photos_loc_gis on photos")
    execute("create index photos_time_id on photos(time_id desc, feature_threshold desc)")
    execute("create index photos_time on photos(time desc,feature_threshold desc)")
    execute("create index photos_loc_gis on photos(location_longitude, location_latitude, time_id, feature_threshold desc)")
    execute("alter table photos drop column user_id")

    execute("drop table users")
  end
end
