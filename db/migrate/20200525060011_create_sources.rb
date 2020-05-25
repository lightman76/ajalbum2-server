class CreateSources < ActiveRecord::Migration[6.0]
  def up
    execute("create table sources(id bigint primary key, raw_name varchar(2048) not null, display_name varchar(255) not null, created_at timestamp null default null, updated_at timestamp null default null)")
  end
  def down
    execute("drop table sources")
  end
end
