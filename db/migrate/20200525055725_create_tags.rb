class CreateTags < ActiveRecord::Migration[6.0]
  def up
    execute("create table tags(id bigint primary key, tag_type varchar(32) not null default 'tag', name varchar(255) not null, location_latitude double null default null, location_longitude double null default null, event_date timestamp null default null, created_at timestamp null default null, updated_at timestamp null default null)")
    execute("create index tag_type_name on tags(tag_type,name)")
    execute("create index tag_type_gis on tags(tag_type,location_longitude, location_latitude)")
    execute("create index tag_type_event_date on tags(tag_type, event_date, name)")
  end
  def down
    execute("drop table tags")
  end
end
