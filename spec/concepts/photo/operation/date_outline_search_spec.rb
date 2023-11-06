require 'rails_helper'

RSpec.describe ::Photo::Operation::DateOutlineSearch do

  context "Basic tests" do
    before :each do
      uop = ::User::Operation::CreateUser.(params: { user: { user_name: 'George' } })
      @user = uop["user"]

      op = ::Source::Create.(params: { raw_name: 'unknown', display_name: 'Unknown', user: @user })
      expect(op).to be_success
      @source_id = source_id = op[:model].id
      #manually create a set of a few photos in the database to test on (without creating files)
      @p1t = DateTime.now - 5.days
      @p1 = ::Photo.create(:title => "Sunset at Mykonos",
                           time_id: @p1t.to_i,
                           time: @p1t,
                           date_bucket: @p1t.strftime("%Y%m%d"),
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "Mykonos, GR",
                           description: "Sunset looking over windmills and the ocean",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 1,
                           image_versions: {},
                           user: @user
      )
      expect(@p1.id).not_to be_nil
      @p2t = DateTime.now - 5.years
      @p2 = ::Photo.create(:title => "Sunset at Grand Canyon",
                           time_id: @p2t.to_i,
                           time: @p2t,
                           date_bucket: @p2t.strftime("%Y%m%d"),
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "Supai, AZ",
                           description: "Sunset at Havasu Falls",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 2,
                           image_versions: {},
                           user: @user
      )
      @p3t = DateTime.now - 2.years
      @p3 = ::Photo.create(:title => "Golden Gate Bridge",
                           time_id: @p3t.to_i,
                           date_bucket: @p3t.strftime("%Y%m%d"),
                           time: @p3t,
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "San Francisco, CA",
                           description: "The Golden Gate Bridge looking out to the ocean",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 0,
                           image_versions: {},
                           user: @user
      )
      @p4t = DateTime.now - 7.years
      @p4 = ::Photo.create(:title => "Yosemite Valley",
                           time_id: @p4t.to_i,
                           time: @p4t,
                           date_bucket: @p4t.strftime("%Y%m%d"),
                           taken_in_tz: -5 * 60 * 60,
                           location_name: "Yosemite National Park",
                           description: "View from Glacier Point",
                           source_id: source_id,
                           metadata: {},
                           tags: {},
                           feature_threshold: 0,
                           image_versions: {},
                           user: @user
      )
    end

    def date_str(d)
      sprintf("%04d-%02d-%02d", d.year, d.month, d.day)
    end

    it "should return correct results for no filter" do
      result = ::Photo::Operation::DateOutlineSearch.(params: { search: { timezone_offset_min: -5 * 60, user: 'George', offset_date: date_str(Time.now) } })
      expect(result.success?).to be_truthy
      results_by_date = result["result_count_by_date"]
      expect(results_by_date).not_to be_nil
      expect(results_by_date.length).to eq(4)
      #now check order
      expect(results_by_date[0][:date]).to eq(date_str(@p1t))
      expect(results_by_date[0][:num_items]).to eq(1)
      expect(results_by_date[1][:date]).to eq(date_str(@p3t))
      expect(results_by_date[1][:num_items]).to eq(1)
      expect(results_by_date[2][:date]).to eq(date_str(@p2t))
      expect(results_by_date[2][:num_items]).to eq(1)
      expect(results_by_date[3][:date]).to eq(date_str(@p4t))
      expect(results_by_date[3][:num_items]).to eq(1)
    end

    it "should return correct results for no filter with multiple on a date" do
      p5t = @p3t + 5.minutes
      p5 = ::Photo.create(:title => "Golden Gate Bridge At sunset",
                          time_id: p5t.to_i,
                          time: p5t,
                          date_bucket: p5t.strftime("%Y%m%d"),
                          taken_in_tz: -5 * 60 * 60,
                          location_name: "San Francisco, CA",
                          description: "The Golden Gate Bridge looking out to the ocean at sunset",
                          source_id: @source_id,
                          metadata: {},
                          tags: {},
                          feature_threshold: 0,
                          image_versions: {},
                          user: @user
      )

      result = ::Photo::Operation::DateOutlineSearch.(params: { search: { timezone_offset_min: -5 * 60, user: 'George', offset_date: date_str(Time.now) } })
      expect(result.success?).to be_truthy
      results_by_date = result["result_count_by_date"]
      expect(results_by_date).not_to be_nil
      expect(results_by_date.length).to eq(4)
      #now check order
      expect(results_by_date[0][:date]).to eq(date_str(@p1t))
      expect(results_by_date[0][:num_items]).to eq(1)
      expect(results_by_date[1][:date]).to eq(date_str(@p3t))
      expect(results_by_date[1][:num_items]).to eq(2)
      expect(results_by_date[2][:date]).to eq(date_str(@p2t))
      expect(results_by_date[2][:num_items]).to eq(1)
      expect(results_by_date[3][:date]).to eq(date_str(@p4t))
      expect(results_by_date[3][:num_items]).to eq(1)
    end
  end
end
#