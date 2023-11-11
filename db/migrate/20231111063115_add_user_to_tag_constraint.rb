class AddUserToTagConstraint < ActiveRecord::Migration[6.0]
  def up
    execute("alter table tags drop constraint shortcut_url")
    execute("create unique index user_tags_by_shortcut_url on tags(user_id, shortcut_url)")
  end

  def down
    execute("drop index user_tags_by_shortcut_url on tags")
    execute("create unique index shortcut_url on tags(shortcut_url)")
  end
end
