#!/usr/bin/env ruby
#
# This file exports photos from the old JAlbum Java photos site and creates the JSON metadata files which can be imported by ajalbum2-server
#

require 'mysql2'
require 'json'
require 'getoptlong'

USAGE = "Coming soon to a CLI near you"

opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--host', '-H', GetoptLong::REQUIRED_ARGUMENT],
    ['--port', '-p', GetoptLong::REQUIRED_ARGUMENT],
    ['--database', '-d', GetoptLong::REQUIRED_ARGUMENT],
    ['--user', '-u', GetoptLong::REQUIRED_ARGUMENT],
    ['--password', '-P', GetoptLong::REQUIRED_ARGUMENT],
    ['--output-file', GetoptLong::REQUIRED_ARGUMENT],
    ['--start-date', GetoptLong::OPTIONAL_ARGUMENT],
    ['--end-date', GetoptLong::OPTIONAL_ARGUMENT],
)

class LegacyExport
  def initialize(host:, port:, database:, db_user:, db_password:, output_file:, start_date: nil, end_date: nil)
    @host = host
    @port = port
    @database = database
    @db_user = db_user
    @db_password = db_password
    @output_file = output_file
    @start_date = start_date
    @end_date = end_date
  end

  def do_export()
    File.open(@output_file, "w") do |out|
      out << "{\"photos\":[\n"
      conn = get_connection()
      photo_query_details = create_photo_query()
      photo_statement = conn.prepare(photo_query_details[:query])
      photo_results = photo_statement.execute(*photo_query_details[:params])
      is_first = true
      photo_results.each do |photo_row|
        out << ",\n" unless is_first
        is_first = false
        json = create_photo_json(photo_row)
        out << json.to_json if json
        puts "  Exported #{json[:taken_timestamp]}" if json
        unless json
          puts "Failed to export for #{photo_row.inspect}"
        end
      end
      out << "\n]}\n"
    end
  end

  def create_photo_json(photo_row)
    gid = photo_row["cnt_gid"]
    json = {
        taken_timestamp: photo_row["cnt_ContentDate"].strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
        title: photo_row["cnt_name"],
        description: photo_row["cnt_description"],
        original_content_type: "image/jpeg",
        taken_in_tz: "-05:00"
    }
    evt = photo_row["cnt_event"]
    if evt && !evt.empty?
      json[:tag_events] = [evt]
    end
    people = photo_row["cnt_people"]
    if people && !people.empty?
      json[:tag_people] = people.split(",").collect { |p| p.strip.chomp }
    end

    conn = get_connection2()

    results = conn.query("select cnp_path from t_jacnp_contentpiece where cnp_type=8192 and cnp_parentgid='#{gid}'")
    results.each do |cnp_row|
      json[:from_original_file_path] = cnp_row["cnp_path"]
      #now extract original file name from this path
      json[:original_file_name] = File.basename(cnp_row["cnp_path"])
    end
    unless json[:from_original_file_path]
      return nil #can't go on without the file...
    end


    results = conn.query("select cna_name, cna_value from t_jacna_contentattribute where cna_name in ('Make','Model') and cna_parentgid='#{gid}'")
    make = nil
    model = nil
    results.each do |row|
      make = row["cna_value"] if row["cna_name"] == 'Make'
      model = row["cna_value"] if row["cna_name"] == 'Model'
    end
    if make && model
      json[:source_name] = "#{make} #{model}"
    else
      json[:source_name] = 'Unknown'
    end

    #now look if photo is in an album
    album_names = []
    results = conn.query("select a.alb_name from t_jaalb_album a inner join t_jaale_albumelement e on a.alb_gid=e.ale_parentgid where e.ale_contentchildgid='#{gid}'")
    results.each do |row|
      album_names << row["alb_name"]
    end
    json[:tag_albums] = album_names if album_names.length > 0

    json
  end

  def create_photo_query()
    has_where = false
    query_photos_params = []
    query_photos = "select cnt_gid, cnt_name, cnt_event, cnt_people, cnt_ContentDate, cnt_description from t_jacnt_content "
    if @start_date
      if has_where
        query_photos += " and "
      else
        has_where = true
        query_photos += "where "
      end
      query_photos += "cnt_ContentDate >= ? "
      query_photos_params << @start_date
    end
    if @end_date
      if has_where
        query_photos += " and "
      else
        has_where = true
        query_photos += "where "
      end
      query_photos += "cnt_ContentDate < ? "
      query_photos_params << @end_date
    end
    query_photos += "order by cnt_ContentDate "
    {query: query_photos, params: query_photos_params}
  end

  #A second cached connection to make the one off queries for each photo
  def get_connection2()
    unless @db_conn2
      @db_conn2 = get_connection
    end
    @db_conn2
  end

  def get_connection()
    @host = "127.0.0.1" if @host == "localhost"
    conn_info = {
        :host => @host,
        :port => @port || 3306,
        :username => @db_user,
        :password => @db_password,
        :database => @database
    }
    begin
      db_conn = Mysql2::Client.new(conn_info)
      return db_conn
    rescue Mysql2::Error => e
      puts "Couldn't connect to mySQL server:"
      puts e.message
      exit
    end
  end
end


def parse_date(dstr)
  return nil if dstr.nil? || dstr.empty?
  parts = dstr.split("-")
  DateTime.new(parts[0].to_i, parts[1].to_i, parts[2].to_i)
end

def process_args(opts)
  host = nil
  port = nil
  user = nil
  password = nil
  database = nil
  start_date = nil
  end_date = nil
  output_file = nil
  opts.each do |opt, arg|
    case opt
    when '--help'
      puts USAGE
      exit 0
    when '--host'
      host = arg
    when '--port'
      port = arg.to_i
    when '--database'
      database = arg
    when '--user'
      user = arg
    when '--password'
      password = arg
    when '--start-date'
      start_date = parse_date(arg)
    when '--end-date'
      end_date = parse_date(arg)
    when '--output-file'
      output_file = arg
    end
  end
  unless host && port && database && output_file && user && password
    puts "Missing required database and output file"
    exit 2
  end
  #Now create an exporter class with these parameters and generate the JSON file...
  LegacyExport.new(host: host, port: port, database: database, db_user: user, db_password: password, output_file: output_file, start_date: start_date, end_date: end_date).do_export
end

process_args(opts)


