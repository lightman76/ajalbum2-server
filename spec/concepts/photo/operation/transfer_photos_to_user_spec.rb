require 'rails_helper'

RSpec.describe Photo::Operation::Create do
  before :each do
    APP_CONFIG["defaults"]["timezone_offset_str"] = "-05:00"
    APP_CONFIG["defaults"]["timezone_offset"] = -300
    uop = ::User::Operation::CreateUser.(params: { user: { user_name: 'George' } })
    @user1 = uop["user"]

    op = User::Operation::CreateUserToken.(params: { user: @user1 })
    expect(op.success?).to be_truthy
    @auth1 = op[:token]

    uop = ::User::Operation::CreateUser.(params: { user: { user_name: 'Bob' } })
    @user2 = uop["user"]

    op = User::Operation::CreateUserToken.(params: { user: @user2 })
    expect(op.success?).to be_truthy
    @auth2 = op[:token]

    op = ::Source::Create.(params: { raw_name: 'unknown', display_name: 'Unknown', user: @user1 })
    expect(op).to be_success
    @test1jpg = File.open(File.join(Rails.root, "spec", "test_files", "test_file1.jpg"))

    t = DateTime.now
    params = { "photo": { "image_stream": @test1jpg, "time": t, "title": "Test Photo", source_name: 'unknown', "original_file_name": "test1.jpg", user: @user1 } }
    result = ::Photo::Operation::Create.(params: params)
    expect(result).to be_success
    @photo1 = result["model"]

  end

  after :each do
    @test1jpg.close
    cleanup_test_photos
  end

  it "should move the photos between users" do
    op = ::Photo::Operation::TransferPhotosToUser.(params: {
      user: @user1,
      authorization: @auth1,
      to_user: @user2,
      to_user_authorization: @auth2,
      photo_time_ids: [@photo1.time_id]
    }
    )
    expect(op.success?).to be_truthy
    p = Photo.get(@photo1.id)
    expect(p.user_id).to eq(@user2.id)
    expect(p.source.user_id).to eq(@user2.id)
    from_path_orig = File.join(PhotoUtils.originals_path(@user1.id), p.image_versions["original"]["relative_path"])
    to_path_orig = File.join(PhotoUtils.originals_path(@user2.id), p.image_versions["original"]["relative_path"])
    to_fullres_full_path = File.join(PhotoUtils.generated_images_path(@user2.id), p.image_versions["fullRes"]["relative_path"])

    # Make sure these exist under the new user
    expect(File.exists?(from_path_orig)).to be_falsey
    expect(File.exists?(to_path_orig)).to be_truthy
    expect(File.exists?(to_fullres_full_path)).to be_truthy

    # TODO: test tag transfer

  end

end
