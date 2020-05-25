class CreatePhotoTags < ActiveRecord::Migration[6.0]
  def up
    execute("create table photo_tags(id bigint primary key, photo_id bigint not null, tag_id bigint not null, time_id bigint not null, created_at timestamp null default null, updated_at timestamp null default null)")
    execute("create index photo_tag_idx on photo_tags(tag_id, time_id asc)")
  end
  def down
    execute("drop table photo_tags")
  end
end
