require 'rails_helper'

RSpec.describe Photo::Operation::Create do
  before :each do
    uop = ::User::Operation::CreateUser.(params: { user: { username: 'George' } })
    @user = uop["user"]

    op = ::Source::Create.(params: { raw_name: 'unknown', display_name: 'Unknown', user: @user })
    expect(op).to be_success
    @test1jpg = File.open(File.join(Rails.root, "spec", "test_files", "test_file1.jpg"))
  end

  after :each do
    @test1jpg.close
    cleanup_test_photos
  end

  it "should create generated images" do
    t = DateTime.now
    params = { "photo": { "image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', "original_file_name": "test1.jpg", user: @user } }
    result = ::Photo::Operation::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
    m = result["model"]
    orig = m.image_versions["original"]
    expect(orig).not_to be_nil
    expect(orig["content_type"]).to eq("image/jpeg")
    expect(orig["root_store"]).to eq("originals")
    expect(orig["relative_path"]).not_to be_nil
    expect(File.exists?(File.join(PhotoUtils.originals_path, orig["relative_path"]))).to be_truthy
    thumb = m.image_versions["thumb"]
    expect(thumb).not_to be_nil
    expect(thumb["content_type"]).to eq("image/jpeg")
    expect(thumb["version"]).to eq(1)
    expect(thumb["root_store"]).to eq("generated")
    expect(thumb["relative_path"]).not_to be_nil
    expect(File.exists?(File.join(PhotoUtils.generated_images_path, thumb["relative_path"]))).to be_truthy
    hd = m.image_versions["screenHd"]
    expect(hd).not_to be_nil
    expect(hd["relative_path"]).not_to be_nil
    expect(File.exists?(File.join(PhotoUtils.generated_images_path, hd["relative_path"]))).to be_truthy
    fr = m.image_versions["fullRes"]
    expect(fr).not_to be_nil
    expect(fr["relative_path"]).not_to be_nil
    expect(File.exists?(File.join(PhotoUtils.generated_images_path, fr["relative_path"]))).to be_truthy
  end

  context "skip generated images" do
    before :each do
      @orig_gen_images = ::Photo::Operation::GenerateImages
      ::Photo::Operation.send :remove_const, "GenerateImages"
      ::Photo::Operation.const_set(:GenerateImages, ::MockGenerateImages)
    end

    after :each do
      ::Photo::Operation.const_set(:GenerateImages, @orig_gen_images)
    end

    it "should create a photo record with correct metadata" do
      t = DateTime.now
      params = { "photo": { "image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', user: @user } }
      result = ::Photo::Operation::Create.(params: params)
      expect(result).to be_success
      expect(result["model"]).not_to be_nil
      m = Photo.get(result["model"].id)
      expect(m.time).to be_within(1.minute).of(DateTime.now)
      expect(m.title).to eq("Test Photo")
      expect(m.source_id).to eq(Source.first.id)
      expect(m.metadata).not_to be_nil
      expect(m.metadata["exposure_time"]).not_to be_nil
      expect(m.feature_threshold).to eq(0)
      expect(m.taken_in_tz).to eq(-5 * 60)
      expect(m.location_latitude).to be_within(0.01).of(29.72)
      expect(m.location_longitude).to be_within(0.01).of(95.75)
    end


    it "should create general tag" do
      t = DateTime.now
      params = { "photo": { "image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_names: ["nature"], feature_threshold: 10, user: @user } }
      result = ::Photo::Operation::Create.(params: params)
      expect(result).to be_success
      expect(result["model"]).not_to be_nil
      m = result["model"]
      expect(m.tags['tags'].length).to eq(1)
      tag = ::Tag.find(m.tags['tags'][0])
      expect(tag.name).to eq("nature")
      expect(tag.tag_type).to eq("tag")
      photo_tags = m.photo_tags
      expect(photo_tags.length).to eq(1)
      expect(photo_tags[0].tag_id).to eq(tag.id)
      expect(photo_tags[0].photo_id).to eq(m.id)
      expect(m.feature_threshold).to eq(10)
    end

    it "should create person tag" do
      t = DateTime.now
      params = { "photo": { "image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_people: ["George Washington"], feature_threshold: nil, user: @user } }
      result = ::Photo::Operation::Create.(params: params)
      expect(result).to be_success
      expect(result["model"]).not_to be_nil
      m = result["model"]
      expect(m.tags['tags'].length).to eq(1)
      tag = ::Tag.find(m.tags['tags'][0])
      expect(tag.name).to eq("George Washington")
      expect(tag.tag_type).to eq("people")
      expect(m.feature_threshold).to eq(0)
    end

    it "should create event tag" do
      t = DateTime.now
      params = { "photo": { "image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_events: ["Washington DC Trip"], user: @user } }
      result = ::Photo::Operation::Create.(params: params)
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
      params = { "photo": { "image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', tag_locations: ["Home Base"], user: @user } }
      result = ::Photo::Operation::Create.(params: params)
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
end

class ::MockGenerateImages < Trailblazer::Operation
  step :just_pass

  def just_pass(options, **)
    true
  end

  class Thumbnail < self
  end

  class ScreenHd < self
  end

  class FullRes < self
  end
end
