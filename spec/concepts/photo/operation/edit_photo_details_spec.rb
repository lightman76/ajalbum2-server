require 'rails_helper'
require 'time'

RSpec.describe ::Photo::Operation::EditPhotoDetails do

  context "Basic tests" do
    before :each do
      op = ::User::Operation::CreateUser.(params: { user: { username: "fred" } })
      @user = op[:user]

      op = ::User::Operation::CreateUserToken.(params: { user: 'fred' })
      @authorization = op["token"]

      op = ::Source::Create.(params: { raw_name: 'unknown', display_name: 'Unknown', user: @user })
      expect(op).to be_success
      source_id = op[:model].id
      #manually create a set of a few photos in the database to test on (without creating files)
      @p1t = DateTime.now - 5.days
      @p1 = ::Photo.create(:title => "Sunset at Mykonos",
                           time_id: @p1t.to_i,
                           time: @p1t,
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "Mykonos, GR",
                           description: "Sunset looking over windmills and the ocean",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 1,
                           image_versions: {},
                           user: @user,
      )
      expect(@p1.id).not_to be_nil
      @p2t = DateTime.now - 5.years
      @p2 = ::Photo.create(:title => "Sunset at Grand Canyon",
                           time_id: @p2t.to_i,
                           time: @p2t,
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "Supai, AZ",
                           description: "Sunset at Havasu Falls",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 2,
                           image_versions: {},
                           user: @user,
      )
      @p3t = DateTime.now - 2.years
      @p3 = ::Photo.create(:title => "Golden Gate Bridge",
                           time_id: @p3t.to_i,
                           time: @p3t,
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "San Francisco, CA",
                           description: "The Golden Gate Bridge looking out to the ocean",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 0,
                           image_versions: {},
                           user: @user,
      )
      @p4t = DateTime.now - 7.years
      @p4 = ::Photo.create(:title => "Yosemite Valley",
                           time_id: @p4t.to_i,
                           time: @p4t,
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "Yosemite National Park",
                           description: "View from Glacier Point",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 0,
                           image_versions: {},
                           user: @user,
      )
      op = ::Tag::GetOrCreate.(params: { "tag": { "user": "fred", "tag_type": "tag", "name": "Tag 1" } })
      @tag1 = op["tag"]
      op = ::Tag::GetOrCreate.(params: { "tag": { "user": "fred", "tag_type": "tag", "name": "Tag 2" } })
      @tag2 = op["tag"]
      op = ::Tag::GetOrCreate.(params: { "tag": { "user": "fred", "tag_type": "people", "name": "Person 1" } })
      @person_tag1 = op["tag"]
      op = ::Tag::GetOrCreate.(params: { "tag": { "user": "fred", "tag_type": "people", "name": "Person 2" } })
      @person_tag2 = op["tag"]
    end

    it "should update multiple photos all fields" do
      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id, @p4.id],
        updated_title: "Beautiful landscapes",
        updated_description: "Sweeping vistas",
        updated_feature_threshold: 11,
        add_tags: [@tag1.id, @person_tag1.id]
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(2)

      p1 = @p1.reload
      p4 = @p4.reload
      p2 = @p2.reload
      expect(p1.title).to eq("Beautiful landscapes")
      expect(p1.description).to eq("Sweeping vistas")
      expect(p1.feature_threshold).to eq(11)
      expect(p1.photo_tags.length).to eq(2)
      expect(p1.tags["tags"].length).to eq(2)
      expect(p1.tags["tags"]).to eq([@tag1.id, @person_tag1.id])
      expect(p1.photo_tags.order(:tag_id).first.tag_id).to eq(@tag1.id)

      expect(p4.title).to eq("Beautiful landscapes")
      expect(p4.description).to eq("Sweeping vistas")
      expect(p4.feature_threshold).to eq(11)
      expect(p4.photo_tags.length).to eq(2)
      expect(p4.tags["tags"].length).to eq(2)
      expect(p4.tags["tags"]).to eq([@tag1.id, @person_tag1.id])
      expect(p4.photo_tags.order(:tag_id).first.tag_id).to eq(@tag1.id)

      expect(p2.title).to eq("Sunset at Grand Canyon")
      expect(p2.photo_tags.length).to eq(0)
    end

    it "should only update title" do
      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id, @p4.id],
        updated_title: "Beautiful landscapes",
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(2)

      p1 = @p1.reload
      p4 = @p4.reload
      p2 = @p2.reload
      expect(p1.title).to eq("Beautiful landscapes")
      expect(p1.description).to eq("Sunset looking over windmills and the ocean")
      expect(p1.feature_threshold).to eq(1)
      expect(p1.photo_tags.length).to eq(0)
      expect(p1.tags["tags"].length).to eq(0)

      expect(p4.title).to eq("Beautiful landscapes")
      expect(p4.description).to eq("View from Glacier Point")
      expect(p4.feature_threshold).to eq(0)
      expect(p4.photo_tags.length).to eq(0)
      expect(p4.tags["tags"].length).to eq(0)

      expect(p2.title).to eq("Sunset at Grand Canyon")
      expect(p2.photo_tags.length).to eq(0)
    end

    it "should only update description" do
      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id, @p4.id],
        updated_description: "Beautiful landscapes",
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(2)

      p1 = @p1.reload
      p4 = @p4.reload
      expect(p1.title).to eq("Sunset at Mykonos")
      expect(p1.description).to eq("Beautiful landscapes")
      expect(p1.feature_threshold).to eq(1)
      expect(p1.photo_tags.length).to eq(0)
      expect(p1.tags["tags"].length).to eq(0)

      expect(p4.title).to eq("Yosemite Valley")
      expect(p4.description).to eq("Beautiful landscapes")
      expect(p4.feature_threshold).to eq(0)
      expect(p4.photo_tags.length).to eq(0)
      expect(p4.tags["tags"].length).to eq(0)
    end

    it "should add tags only to photos currently without them" do
      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id],
        add_tags: [@person_tag1]
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(1)

      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id, @p4.id],
        add_tags: [@person_tag1]
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(2)

      p1 = @p1.reload
      p4 = @p4.reload
      expect(p1.photo_tags.length).to eq(1)
      expect(p1.tags["tags"].length).to eq(1)
      expect(p4.photo_tags.length).to eq(1)
      expect(p4.tags["tags"].length).to eq(1)
      expect(p1.tags["tags"]).to eq([@person_tag1.id])
      expect(p1.photo_tags.first.tag_id).to eq(@person_tag1.id)
      expect(p4.tags["tags"]).to eq([@person_tag1.id])
      expect(p4.photo_tags.first.tag_id).to eq(@person_tag1.id)
    end

    it "should remove tags only on photos currently with them" do
      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id],
        add_tags: [@person_tag1]
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(1)
      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id, @p4.id],
        add_tags: [@tag1]
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(2)

      op = ::Photo::Operation::EditPhotoDetails.(params: {
        authorization: @authorization,
        user: "fred",
        photo_ids: [@p1.id, @p4.id],
        remove_tags: [@person_tag1.id]
      })
      expect(op.success?).to be_truthy
      expect(op["update_cnt"]).to eq(2)

      p1 = @p1.reload
      p4 = @p4.reload
      expect(p1.photo_tags.length).to eq(1)
      expect(p1.tags["tags"].length).to eq(1)
      expect(p4.photo_tags.length).to eq(1)
      expect(p4.tags["tags"].length).to eq(1)
      expect(p1.tags["tags"]).to eq([@tag1.id])
      expect(p1.photo_tags.first.tag_id).to eq(@tag1.id)
      expect(p4.tags["tags"]).to eq([@tag1.id])
      expect(p4.photo_tags.first.tag_id).to eq(@tag1.id)
    end

  end
end