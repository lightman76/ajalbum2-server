require "mini_magick"

require_relative "../contract/create"

class Photo::Operation::GenerateImages < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::GenerateImages)
  step Contract::Validate()

  step :process_image

  def process_image(options, model:, params:, **)
    photo_model = params[:photo_model]
    autorotate = params[:autorotate]
    original_file_path = File.join(PhotoUtils.originals_path, photo_model.image_versions["original"]["relative_path"])
    original_retry_cnt = photo_model.image_versions["original"]["retry_count"]
    variant_relative_path = file_relative_path(photo_model, get_variant(), original_retry_cnt)
    variant_full_path = File.join(PhotoUtils.generated_images_path, variant_relative_path)
    FileUtils.mkdir_p(File.dirname(variant_full_path))

    create_resized_image(original_file_path, variant_full_path, autorotate)

    get_image_dims(variant_full_path)

    photo_model.image_versions[get_variant()] = {
      "root_store": "generated",
      "relative_path": variant_relative_path,
      "content_type": "image/jpeg",
      "retry_cnt": original_retry_cnt,
      "version": 1,
      "width": @width,
      "height": @height,
    }
    true
  end

  def get_variant
    raise "unimplemented"
  end

  def get_image_dims(image_path)
    image = MiniMagick::Image.open(image_path)
    @width = image[:width]
    @height = image[:height]
  end

  def create_resized_image(original_file_path, variant_full_path, autorotate)
    raise "unimplemented"
  end

  class Thumbnail < self

    def get_variant
      'thumb'
    end

    def create_resized_image(original_file_path, variant_full_path, autorotate)
      # thumbnail pipeline
      # convert ~/Downloads/test.jpg
      # -auto-orient
      # -filter Triangle
      # -define filter:support=2
      # -resize "300x300^"
      # -gravity center
      # -extent 300x300
      # -unsharp 0.25x0.25+8+0.065
      # -dither None
      # -posterize 136
      # -quality 60
      # -define jpeg:fancy-upsampling=off
      # -interlace none
      # -colorspace sRGB
      # -strip
      # ~/tmp/thumb-test.jpg
      status = MiniMagick::Tool::Convert.new do |convert|
        convert << original_file_path
        convert.merge! ["-auto-orient"] if autorotate
        convert.merge! ["-filter", "Triangle",
                        "-define", "filter:support=2",
                        "-resize", "300x300^",
                        "-gravity", "center",
                        "-extent", "300x300",
                        "-unsharp", "0.25x0.25+8+0.065",
                        "-dither", "None",
                        "-posterize", "136",
                        "-quality", "60",
                        "-define", "jpeg:fancy-upsampling=off",
                        "-interlace", "none",
                        "-colorspace", "sRGB",
                        "-strip"
                       ]
        convert << variant_full_path
      end
      Rails.logger.info("  Resize Thumbnail: Returned #{status.inspect}")
      true
    end
  end


  class ScreenHd < self
    def get_variant
      'screenHd'
    end

    def create_resized_image(original_file_path, variant_full_path, autorotate)
      # convert ~/Downloads/testPeruOrig.jpg
      # -auto-orient
      # -filter Triangle
      # -define filter:support=2
      # -resize "1920x1920"
      # -unsharp 0.25x0.08+8.3+0.045
      # -dither None
      # -posterize 136
      # -quality 60
      # -define jpeg:fancy-upsampling=off
      # -interlace plane
      # -colorspace sRGB
      # -strip
      # ~/Downloads/testPeru1b.jpg
      MiniMagick::Tool::Convert.new do |convert|
        convert << original_file_path
        convert.merge! ["-auto-orient"] if autorotate
        convert.merge! ["-filter", "Triangle",
                        "-define", "filter:support=2",
                        "-resize", "1920x1920",
                        "-unsharp", "0.25x0.08+8.3+0.045",
                        "-dither", "None",
                        "-posterize", "136",
                        "-quality", "60",
                        "-define", "jpeg:fancy-upsampling=off",
                        "-interlace", "plane",
                        "-colorspace", "sRGB",
                        "-strip"
                       ]
        convert << variant_full_path
      end
      true
    end
  end

  class FullRes < self
    def get_variant
      'fullRes'
    end

    def create_resized_image(original_file_path, variant_full_path, autorotate)
      # convert ~/Downloads/testPeruOrig.jpg
      # -auto-orient
      # -filter Triangle
      # -define filter:support=2
      # -unsharp 0.25x0.08+8.3+0.045
      # -dither None
      # -posterize 136
      # -quality 60
      # -define jpeg:fancy-upsampling=off
      # -interlace plane
      # -colorspace sRGB
      # -strip
      # ~/Downloads/testPeru1b.jpg
      MiniMagick::Tool::Convert.new do |convert|
        puts "\n\n Running convert with autorotate=#{autorotate} on #{original_file_path}\n\n"
        convert << original_file_path
        convert.merge! ["-auto-orient"] if autorotate
        convert.merge! ["-filter", "Triangle",
                        "-define", "filter:support=2",
                        "-unsharp", "0.25x0.08+8.3+0.045",
                        "-dither", "None",
                        "-posterize", "136",
                        "-quality", "60",
                        "-define", "jpeg:fancy-upsampling=off",
                        "-interlace", "plane",
                        "-colorspace", "sRGB",
                        "-strip"
                       ]
        convert << variant_full_path
      end
      true
    end
  end

  def file_relative_path(photo, variant, original_retry_cnt)
    #NOTE: we overwrite generated images but utilize the retry count of the original
    File.join(PhotoUtils.base_path_for_photo(photo), PhotoUtils.file_name_for_photo(photo, variant: variant, retry_cnt: original_retry_cnt))
  end

end
