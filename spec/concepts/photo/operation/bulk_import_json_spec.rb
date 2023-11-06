require 'rails_helper'

RSpec.describe Photo::Operation::BulkImportJson do
  before :each do
    uop = ::User::Operation::CreateUser.(params: { user: { user_name: 'George' } })
    @user = uop["user"]

    ##
    op = ::Source::Create.(params: { raw_name: 'unknown', display_name: 'Unknown', user: @user })
    expect(op).to be_success
    # File.join(Rails.root, "spec", "test_files", "test_file1.jpg")
  end

  after :each do
    cleanup_test_photos
  end

  it "should create photo from import" do
    json_data = JSON.parse({
                               photos: [
                                   {
                                       from_original_file_path: File.join("test_files", "test_file1.jpg"),
                                       taken_timestamp: JSON.parse((DateTime.now - 11.days).to_json),
                                       original_file_name: "DSC_1111.jpg",
                                       original_content_type: "image/jpeg",
                                       title: "Awesome sunset",
                                       location_latitude: 0.00,
                                       location_longitude: 60.00,
                                       location_name: "Bumble",
                                       source_name: "Unknown",
                                       description: "Over the ocean",
                                       metadata: {},
                                       tag_names: ["Tag 1", "Tag 2"],
                                       tag_people: ["Derf Elwom"],
                                       tag_events: ["Fashion Friday"],
                                       feature_threshold: 0
                                   }
                               ]
                           }.to_json)

    result = ::Photo::Operation::BulkImportJson.(params: { user: @user, import_photo_root: File.join(Rails.root, "spec"), json_data: json_data })
    expect(result.success?).to be_truthy
    expect(result[:success_count]).to eq(1)
    expect(result[:failure_count]).to eq(0)
  end
end