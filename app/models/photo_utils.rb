class PhotoUtils

  def self.temporary_upload_dir()
    return APP_CONFIG["photo_storage"]["tmp_upload_path"]
  end

  def self.originals_path()
    return APP_CONFIG["photo_storage"]["originals_path"]
  end

  def self.generated_images_path()
    return APP_CONFIG["photo_storage"]["generated_images_path"]
  end


  #This is the relative path for the photo within the originals or generated dirs
  # Put photos into sub directories based on the photo date stamp we've found.
  def self.base_path_for_photo(photo)
    photo_date = photo.time
    sprintf("%04d/%02d/%02d", photo_date.year, photo_date.month, photo_date.day)
  end

  def self.get_extension_for_photo(photo, variant = nil)
    orig_name = photo.metadata["original_file_name"]
    if orig_name
      idx = orig_name.reverse.index('.')
      if idx
        original_extension = orig_name[(orig_name.length - idx)..(orig_name.length)]
        #for now just assuming jpg so original will match the variants
        return original_extension
      end
    end
    #didn't find it by extension
    orig_content_type = photo.metadata["original_content_type"]
    return "jpg" if orig_content_type && photo.metadata["original_file_name"] == "image/jpeg"

    return "jpg" #default to jpg, will be most of what we deal with anyway
  end

  # Name the files by the date we have.  Variant for generated image type and retry when we have a name collision
  def self.file_name_for_photo(photo, variant: nil, retry_cnt: nil)
    photo_date = photo.time.to_datetime #it's some activerecord bastard class, get a datetime from it
    photo_extension = get_extension_for_photo(photo, variant)
    photo_file_name = sprintf("%04d-%02d-%02d_%02d-%02d-%02d", photo_date.year, photo_date.month, photo_date.day, photo_date.hour, photo_date.minute, photo_date.second)
    "#{photo_file_name}#{variant ? "_#{variant}" : ""}#{retry_cnt ? "__#{retry_cnt}" : ""}.#{photo_extension}"
  end
end