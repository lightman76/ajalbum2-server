require 'pathname'

class Photo::Operation::TransferPhotosToUser < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::TransferPhotosToUser)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user
  step :hydrate_to_user
  step :validate_authorization_to_access_user
  step :validate_authorization_to_access_dest_user
  step :hydrate_photos
  step :move_photos

  def move_photos(options, user:, to_user:, photos:, **)
    tag_mapping = {}
    source_mapping = {}
    photos.each do |photo|
      # start by making a list of the tags on the photo from the src user
      photo_tag_list = []
      photo.tags["tags"].each do |tid|
        to_tag = tag_mapping[tid]
        unless to_tag
          from_tag = Tag.get(tid)
          to_tag = Tag.where(user_id: to_user.id, tag_type: from_tag.type, name: from_tag.name).first
          if to_tag
            tag_mapping[tid] = to_tag
          else
            to_tag = from_tag.dup
            to_tag.user_id = to_user.id
            to_tag.save!
            tag_mapping[tid] = to_tag
          end
        end
        photo_tag_list << to_tag.id
      end

      # ok - have all the tags, now check the source
      to_source = source_mapping[photo.source_id]
      unless to_source
        from_source = photo.source
        to_source = Source.where(user_id: to_user.id, raw_name: from_source.raw_name).first
        if to_source
          source_mapping[photo.source_id] = to_source
        else
          to_source = from_source.dup
          to_source.user_id = to_user.id
          to_source.save!
          source_mapping[photo.source_id] = to_source
        end
      end

      # ok - ready to transfer the photo
      photo.tags["tags"] = photo_tag_list
      photo.source_id = to_source.id
      photo.source_name = to_source.display_name
      photo.user_id = to_user.id

      # TODO: doesn't deal with case where there's a naming conflict!
      # Now need to move the files to the correct user folder
      from_path_orig = File.join(PhotoUtils.originals_path(user.id), photo.image_versions["original"]["relative_path"])
      to_path_orig = File.join(PhotoUtils.originals_path(to_user.id), photo.image_versions["original"]["relative_path"])
      FileUtils.mkdir_p(::Pathname.new(to_path_orig).dirname)
      FileUtils.move(from_path_orig, to_path_orig)

      ["thumb", "screenHd", "fullRes"].each do |variant_name|
        from_variant_full_path = File.join(PhotoUtils.generated_images_path(user.id), photo.image_versions[variant_name]["relative_path"])
        to_variant_full_path = File.join(PhotoUtils.generated_images_path(to_user.id), photo.image_versions[variant_name]["relative_path"])
        FileUtils.mkdir_p(::Pathname.new(to_variant_full_path).dirname)
        FileUtils.move(from_variant_full_path, to_variant_full_path)
      end

      photo.save!

    end

    true
  end

  def hydrate_photos(options, model:, **)
    photos = model.photo_time_ids.collect { |pid| Photo.where(time_id: pid).first }.compact
    unless photos.length > 0
      add_error(options, :photo_time_ids, "Selected photos not found.")
      return false
    end
    options[:photos] = photos
    true
  end

  def hydrate_to_user(options, model:, **)
    model.to_user = User.where(user_name: model.to_user).first if model.to_user.class == String
    options[:to_user] = model.to_user
    unless model.to_user
      add_error(options, :to_user, "Unknown dest user (1)")
      return false
    end
    true
  end

  def validate_authorization_to_access_dest_user(options, model:, to_user:, **)
    raw_token = model.to_user_authorization
    unless raw_token
      add_error(options, :to_user_authorization, "Missing authorization for this operation.")
      return false
    end

    tok_data = JWT.decode(raw_token, APP_CONFIG["jwt"]["keys"]["auth-hmac512"], true, { algorithms: ['HS512'] })
    acting_user = tok_data[0]['sub']
    unless tok_data[0]['aud'] == "AJAlbumServer" && tok_data[0]['iss'] == "AJAlbumServer"
      add_error(options, :to_user_authorization, "Invalid authorization.")
      return false
    end
    exp_date_num = tok_data[0]['exp']
    exp_time = Time.at(exp_date_num)
    unless exp_time > Time.now
      add_error(options, :to_user_authorization, "Authorization has expired.")
      return false
    end

    # OK - Token looks good
    # For now, users can only access their own albums.  In the future may add a lookup table to allow crossing between them
    unless to_user.user_name == tok_data[0]['sub']
      add_error(options, :to_user_authorization, "Authorization not valid for this dest user's album.")
      return false
    end
    return true
  end

end
