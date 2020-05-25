class CreateTags < ActiveRecord::Migration[6.0]
  def up
    execute("create table tags(id bigint primary key, type varchar(32) not null default 'tag', name varchar(255) not null, location_gis POINT, event_date timestamp null default null, created_at timestamp null default null, updated_at timestamp null default null)")
    execute("create index tag_type_name on tags(type,name)")
    execute("create index tag_type_gis on tags(type,location_gis)")
    execute("create index tag_type_event_date on tags(type, event_date, name)")
  end
  def down
    execute("drop table tags")
  end
end
