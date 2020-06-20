class Photo < ApplicationRecord
  belongs_to :source
  has_many :photo_tags
  store :image_versions, coder: JSON
  store :metadata, coder: JSON
  store :tags, coder: JSON

  def self.temporary_upload_dir()
    return File.join(APP_CONFIG['photo_storage']['root_path'], 'tmp_upload')
  end
end