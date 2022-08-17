#!/usr/bin/env ruby

#Load the rails environment
require File.expand_path("../../config/environment", __FILE__)

#TODO use normal command line options to deal with a glob to find the files to process
# and call the operations to load them

require 'optparse'

class BulkLoadPhotos

  class BulkLoadPhotosOptions
    attr_accessor :username, :locations, :events, :general_tags, :albums, :threshold

    def initialize
      @verbose = false
      @locations = []
      @events = []
      @general_tags = []
      @albums = []
      @threshold = 0
    end

    def define_options(parser)
      parser.banner = "Usage: bulk_load_photos.rb [options] <file names...>"
      parser.separator ""
      parser.separator "Specific options:"

      user_option(parser)
      location_option(parser)
      event_option(parser)
      general_tag_option(parser)
      album_option(parser)
      threshold_option(parser)

      parser.separator ""
      parser.separator "Common options:"
      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      parser.on_tail("-h", "--help", "Show this message") do
        puts parser
        exit
      end
    end

    def user_option(parser)
      parser.on("-u", "--user USERNAME",
                "USERNAME to load the photos into (REQUIRED)") do |username|
        puts "Loading into user account #{username}!"
        self.username = username
      end
    end

    def location_option(parser)
      parser.on("-l", "--location LOCATION",
                "Tag all photos with location tag LOCATION") do |location|
        self.locations << location
      end
    end

    def event_option(parser)
      parser.on("-v", "--event EVENT",
                "Tag all photos with event tag EVENT") do |event|
        self.events << event
      end
    end

    def general_tag_option(parser)
      parser.on("-t", "--tag TAG",
                "Tag all photos with general tag TAG") do |general_tag|
        self.general_tags << general_tag
      end
    end

    def album_option(parser)
      parser.on("-a", "--album ALBUM",
                "Tag all photos with album tag ALBUM") do |album_tag|
        self.album_tags << album_tag
      end
    end

    def threshold_option(parser)
      parser.on("-T", "--threshold THRESHOLD",
                "Mark all photos with integer threshold value THRESHOLD.  0=low priority (default), 10=high priority") do |threshold|
        self.threshold = threshold.to_i || 0
      end
    end

  end

  def parse(args)
    # The options specified on the command line will be collected in
    # *options*.

    @options = BulkLoadPhotosOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    end
    @options
  end

  def process_bulk_load(args)
    options = parse(args)
    unless options.username
      puts "Must specify username"
      return false
    end
    relative_file_names = @args.default_argv
    puts "Preparing to process #{relative_file_names.length} files"
    puts "Using parameters user=#{options.username} tags=#{options.general_tags}, location=#{options.locations}, event=#{options.events}, album=#{options.albums}, threshold=#{options.threshold}"

    op = Photo::Operation::BulkLoadFromDisk.(params:
      {
        user: options.username,
        file_list: relative_file_names, #TODO: do I need to convert these to a full path?
        location_tags: options.locations,
        event_tags: options.events,
        general_tags: options.general_tags,
        album_tags: options.albums,
        feature_threshold: options.threshold
      })
    if op.success?
      puts "Import successfully completed"
    else
      puts "Import Failed: #{BaseOperation.human_string_from_op_errors(op)}"
    end
  end

  attr_reader :parser, :options
end

blp = BulkLoadPhotos.new
blp.process_bulk_load(ARGV)