class Photo::Operation::EditPhotoDetails < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::EditPhotoDetails)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user
  step :validate_authorization_to_access_user
  step :hydrate_photos
  step :make_updates
  step :save_updates

  def hydrate_photos(options, model:, **)
    photos = model.photo_time_ids.collect { |pid| Photo.where(time_id: pid).first }.compact
    unless photos.length > 0
      add_error(options, :photo_time_ids, "Selected photos not found.")
      return false
    end
    options[:photos] = photos
    true
  end

  def make_updates(options, model:, user:, photos:, **)

    add_tags = materialize_tags(model.add_tags || [], user)
    remove_tags = materialize_tags(model.remove_tags || [], user)
    forced_rotation = model.forced_rotation
    added_photo_tags = []
    photo_tags_to_delete = []

    photos.each do |photo|
      unless model.updated_title.nil?
        photo.title = model.updated_title
      end
      unless model.updated_description.nil?
        photo.description = model.updated_description
      end
      unless model.updated_feature_threshold.nil?
        photo.feature_threshold = model.updated_feature_threshold
      end

      photo_tags = photo.tags['tags'] || []
      add_tags.each do |tag|
        pt = PhotoTag.where(tag_id: tag.id, photo_id: photo.id).first
        unless pt
          pt = PhotoTag.new(tag_id: tag.id, photo_id: photo.id, time_id: photo.time_id)
          added_photo_tags << pt
          photo_tags << tag.id
        end
      end

      remove_tags.each do |tag|
        pt = PhotoTag.where(tag_id: tag.id, photo_id: photo.id).first
        if pt
          photo_tags_to_delete << pt
          idx = photo_tags.index(tag.id)
          photo_tags.delete_at(idx) if idx
        end
      end

      photo.tags["tags"] = photo_tags

      if forced_rotation
        forced_rotation = forced_rotation.to_i if forced_rotation.class == String
        if forced_rotation == 0 || forced_rotation == 90 || forced_rotation == 180 || forced_rotation == 270
          op_thumb = ::Photo::Operation::GenerateImages::Thumbnail.(params: { photo_model: photo, autorotate: false, forced_rotation: forced_rotation })
          unless op_thumb.success?
            Rails.logger.warn("Failed to recreate rotated thumbnail: #{op_thumb.errors.details.to_json}")
            options[:warnings] << "Failed to create thumbnail: #{op_thumb.errors.details.to_json}"
          end
          op_hd = ::Photo::Operation::GenerateImages::ScreenHd.(params: { photo_model: photo, autorotate: false, forced_rotation: forced_rotation })
          unless op_hd.success?
            Rails.logger.warn("Failed to recreate rotated ScreenHD: #{op_hd.errors.details.to_json}")
            options[:warnings] << "Failed to create ScreenHD: #{op_hd.errors.details.to_json}"
          end
          op_full = ::Photo::Operation::GenerateImages::FullRes.(params: { photo_model: photo, autorotate: false, forced_rotation: forced_rotation })
          unless op_full.success?
            Rails.logger.warn("Failed to recreate rotated FullRes: #{op_full.errors.details.to_json}")
            options[:warnings] << "Failed to create FullRes: #{op_full.errors.details.to_json}"
          end
        end
      end
    end
    options[:added_photo_tags] = added_photo_tags
    options[:photo_tags_to_delete] = photo_tags_to_delete
    true
  end

  def materialize_tags(tags, user)
    tags.collect do |tid|
      tag = tid
      tag = Tag.get(tid) if tag.class == Integer
      tag = Tag.get(tid.to_i) if tag.class == String && /^[0-9]+$/.match(tag)
      tag = Tag.where(name: tid, user_id: user.id).first if tag.class == String && !(/^[0-9]+$/.match(tag))
      tag
    end.compact
  end

  #TODO: will this work for the related tags - may have to track and deal with separately??
  def save_updates(options, photos:, added_photo_tags:, photo_tags_to_delete:, **)
    update_cnt = 0
    Photo.transaction do
      photos.each { |p| p.save!; update_cnt += 1 }
      added_photo_tags.each { |pt| pt.save! }
      photo_tags_to_delete.each { |pt| pt.destroy }
    end
    options[:update_cnt] = update_cnt
    true
  end

end

