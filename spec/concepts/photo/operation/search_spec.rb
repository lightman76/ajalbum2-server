require 'rails_helper'

RSpec.describe ::Photo::Operation::Search do

  context "Basic tests" do
    before :each do
      op = ::Source::Create.(params: {source: {raw_name: 'unknown', display_name: 'Unknown'}})
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
                           image_versions: {}
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
                           image_versions: {}
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
                           image_versions: {}
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
                           image_versions: {}
      )
    end

    it "should return correct results for no filter" do
      result = ::Photo::Operation::Search.(params: {search: {}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(4)
      #now check order
      expect(results[0].id).to eq(@p1.id)
      expect(results[1].id).to eq(@p3.id)
      expect(results[2].id).to eq(@p2.id)
      expect(results[3].id).to eq(@p4.id)
    end

    it "should return correct results for pagination" do
      result = ::Photo::Operation::Search.(params: {search: {offset_date: @p1t - 3.years, target_max_results: 2}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(2)
      #now check order
      expect(results[0].id).to eq(@p2.id)
      expect(results[1].id).to eq(@p4.id)
    end

    it "should return correct results for start_date filter" do
      result = ::Photo::Operation::Search.(params: {search: {start_date: JSON.parse((DateTime.now - 3.years).to_json)}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(2)
      #now check order
      expect(results[0].id).to eq(@p1.id)
      expect(results[1].id).to eq(@p3.id)
    end
    it "should return correct results for end_date filter" do
      result = ::Photo::Operation::Search.(params: {search: {end_date: JSON.parse((DateTime.now - 3.years).to_json)}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(2)
      #now check order
      expect(results[0].id).to eq(@p2.id)
      expect(results[1].id).to eq(@p4.id)
    end

    it "should return correct results for both date filters" do
      result = ::Photo::Operation::Search.(params: {search: {start_date: JSON.parse((DateTime.now - 6.years).to_json), end_date: JSON.parse((DateTime.now - 1.years).to_json)}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(2)
      #now check order
      expect(results[0].id).to eq(@p3.id)
      expect(results[1].id).to eq(@p2.id)
    end
    it "should return correct results for min_threshold" do
      result = ::Photo::Operation::Search.(params: {search: {min_threshold: 1}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(2)
      #now check order
      expect(results[0].id).to eq(@p1.id)
      expect(results[1].id).to eq(@p2.id)
    end
    it "should return correct results for max_threshold" do
      result = ::Photo::Operation::Search.(params: {search: {max_threshold: 1}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(3)
      #now check order
      expect(results[0].id).to eq(@p1.id)
      expect(results[1].id).to eq(@p3.id)
      expect(results[2].id).to eq(@p4.id)
    end
=begin
#NOTE: we can't test mariadb full text query - looks like you can't query on un-committed inserts/updates, and I'm guessing the specs are using transactions to quickly rollback db changes.
    it "should return correct results for full text single word" do
      result = ::Photo::Operation::Search.(params:{search:{search_text: "Sunset"}})
      expect(result.success?).to be_truthy
      results = result["results"]
      expect(results).not_to be_nil
      expect(results.length).to eq(2)
      #now check order
      expect(results[0].id).to eq(@p1.id)
      expect(results[1].id).to eq(@p2.id)
    end
=end

    context "tags: " do
      before :each do
        @ttag1 = ::Tag::GetOrCreate.(params: {tag: {tag_type: "tag", name: "TestTag1"}})["tag"]
        @ttag2 = ::Tag::GetOrCreate.(params: {tag: {tag_type: "tag", name: "TestTag2"}})["tag"]
        @ptag1 = ::Tag::GetOrCreate.(params: {tag: {tag_type: "person", name: "Ronald McDonald"}})["tag"]
        @ptag2 = ::Tag::GetOrCreate.(params: {tag: {tag_type: "person", name: "Roy Rodgers"}})["tag"]

        #TODO: use an operation to do this so it's added to the tags JSON on the photo too
        PhotoTag.create(photo_id: @p1.id, tag_id: @ttag1.id, time_id: @p1.time_id)
        PhotoTag.create(photo_id: @p2.id, tag_id: @ttag1.id, time_id: @p2.time_id)
        PhotoTag.create(photo_id: @p1.id, tag_id: @ptag1.id, time_id: @p1.time_id)
        PhotoTag.create(photo_id: @p4.id, tag_id: @ttag2.id, time_id: @p4.time_id)
        PhotoTag.create(photo_id: @p4.id, tag_id: @ptag2.id, time_id: @p4.time_id)
      end

      it "should find photos for tag tag1" do
        result = ::Photo::Operation::Search.(params: {search: {tags: [@ttag1.id]}})
        expect(result.success?).to be_truthy
        results = result["results"]
        expect(results).not_to be_nil
        expect(results.length).to eq(2)
        #now check order
        expect(results[0].id).to eq(@p1.id)
        expect(results[1].id).to eq(@p2.id)
      end

      it "should find photos for person tag1" do
        result = ::Photo::Operation::Search.(params: {search: {tags: [@ptag1.id]}})
        expect(result.success?).to be_truthy
        results = result["results"]
        expect(results).not_to be_nil
        expect(results.length).to eq(1)
        #now check order
        expect(results[0].id).to eq(@p1.id)
      end

    end

  end
end