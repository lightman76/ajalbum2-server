require 'rails_helper'

RSpec.describe Photo::Create do
  before :each do
    op = ::Source::Create.(params: {source: {raw_name: 'unknown', display_name: 'Unknown'}})
    expect(op).to be_success
    @test1jpg = File.open(File.join(Rails.root, "spec", "test_files", "test_file1.jpg"))
  end

  after :each do
    @test1jpg.close
  end


  it "should create a photo record with correct metadata" do
    t = DateTime.now
    params = {"photo": {"image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown'}}
    result = ::Photo::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
    m = result["model"]
    expect(m.location_latitude).to be_within(0.01).of(29.72)
    expect(m.location_longitude).to be_within(0.01).of(95.75)
  end

  it "should create general tag" do
    t = DateTime.now
    params = {"photo": {"image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_names: ["nature"]}}
    result = ::Photo::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
    m = result["model"]
    expect(m.tags['tags'].length).to eq(1)
    tag = ::Tag.find(m.tags['tags'][0])
    expect(tag.name).to eq("nature")
    expect(tag.tag_type).to eq("tag")
  end

  it "should create person tag" do
    t = DateTime.now
    params = {"photo": {"image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_people: ["George Washington"]}}
    result = ::Photo::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
    m = result["model"]
    expect(m.tags['tags'].length).to eq(1)
    tag = ::Tag.find(m.tags['tags'][0])
    expect(tag.name).to eq("George Washington")
    expect(tag.tag_type).to eq("people")
  end

  it "should create event tag" do
    t = DateTime.now
    params = {"photo": {"image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_events: ["Washington DC Trip"]}}
    result = ::Photo::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
    m = result["model"]
    expect(m.tags['tags'].length).to eq(1)
    tag = ::Tag.find(m.tags['tags'][0])
    expect(tag.name).to eq("Washington DC Trip")
    expect(tag.tag_type).to eq("event")
    expect(tag.event_date).to eq(result["model"].time)
  end

  it "should create location tag" do
    t = DateTime.now
    params = {"photo": {"image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_locations: ["Home Base"]}}
    result = ::Photo::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
    m = result["model"]
    expect(m.tags['tags'].length).to eq(1)
    tag = ::Tag.find(m.tags['tags'][0])
    expect(tag.name).to eq("Home Base")
    expect(tag.tag_type).to eq("location")
    expect(tag.location_latitude).to eq(result["model"].location_latitude)
    expect(tag.location_longitude).to eq(result["model"].location_longitude)
  end
end