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


  it "should create a photo record" do
    t = DateTime.now
    params = {"photo": {"image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown'}}
    result = ::Photo::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
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
end