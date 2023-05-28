class Photo::Operation::DeletePhotos < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::DeletePhotos)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user
  step :validate_authorization_to_access_user
  step :delete_photos

  def delete_photos(options, model:, **)
    delete_count = 0
    model.photo_time_ids.each do |time_id|
      begin
        photo_model = Photo.where(time_id: time_id).first
        if photo_model
          original_file_path = File.join(PhotoUtils.originals_path(photo_model.user_id), photo_model.image_versions["original"]["relative_path"])
          original_retry_cnt = photo_model.image_versions["original"]["retry_count"]
          variant_files = []
          ['fullRes', 'screenHd', 'thumb'].each do |variant_name|
            variant_relative_path = file_relative_path(photo_model, variant_name, original_retry_cnt)
            variant_full_path = File.join(PhotoUtils.generated_images_path(photo_model.user_id), variant_relative_path)
            variant_files << variant_full_path
          end

          # Ok - delete the files now
          variant_files.each { |vf| File.delete(vf) if File.exist?(vf) }
          File.delete(original_file_path) if File.exist?(original_file_path)
          photo_model.photo_tags.find_each do |pt|
            pt.destroy
          end
          photo_model.destroy
          delete_count += 1
        end
      rescue StandardError => e
        Rails.logger.error("Failed while deleting photo: #{photo_model&.id}: #{e.message} #{e.backtrace}")
        binding.pry
      end
    end
    options[:delete_count] = delete_count
  end

end

