require 'json'

namespace :export do
  desc 'Export paths of photos matching a given tag to given path OR standard out'
  task :paths_for_tag, [:tag_id, :opt_file_path] => :environment do |t, args|
    raise "Missing tag id" unless args.tag_id
    tag = Tag.get(args.tag_id)
    raise "Could not find tag for id #{args.tag_id}" unless tag

    out_writer = STDOUT
    begin
      if args.opt_file_path
        out_writer = File.open(args.opt_file_path, "w")
      end

      PhotoTag.where(tag_id: tag.id).joins("inner join photos on photos.id=photo_tags.photo_id").find_each do |pt|
        out_writer << PhotoUtils.originals_path(tag.user_id) + "/" + pt.photo.image_versions["original"]["relative_path"] + "\n"
      end
    ensure
      if args.opt_file_path
        out_writer.close
      end
    end
  end
end
