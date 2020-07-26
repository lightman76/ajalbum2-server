class AddAlbumTags < ActiveRecord::Migration[6.0]
  def up
    execute("alter table tags add column shortcut_url varchar(64) null default null unique, add column description mediumtext")
  end

  def Down
    execute("alter table tags drop column shortcut_url, drop column description")
  end
end
