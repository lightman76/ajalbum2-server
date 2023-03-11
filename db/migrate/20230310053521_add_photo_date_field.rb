class AddPhotoDateField < ActiveRecord::Migration[6.0]
  def up
    execute("alter table photos add column date_bucket int null default null after time")
    execute("create index photos_date_bucket on photos(date_bucket,time)")
  end

  def down
    execute("alter table photos drop column date_bucket")
  end
end
