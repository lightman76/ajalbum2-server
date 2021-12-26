require 'rails_helper'

RSpec.describe ::Tag::Operation::RetrieveTagsById do
  before :each do
    op = ::User::Operation::CreateUser.(params: { user: { user_name: "fred" } })
    @user = op[:user]

    params = { "tag": { "user": "fred", "tag_type": "tag", "name": "Test Tag 1" } }
    result = ::Tag::GetOrCreate.(params: params)
    expect(result).to be_success
    @tag1 = result["tag"]

    params = { "tag": { "user": "fred", "tag_type": "tag", "name": "Test Tag 2" } }
    result = ::Tag::GetOrCreate.(params: params)
    expect(result).to be_success
    @tag2 = result["tag"]

    params = { "tag": { "user": "fred", "tag_type": "people", "name": "John Doe" } }
    result = ::Tag::GetOrCreate.(params: params)
    expect(result).to be_success
    @person_tag1 = result["tag"]

    params = { "tag": { "user": "fred", "tag_type": "people", "name": "Suzy Queue" } }
    result = ::Tag::GetOrCreate.(params: params)
    expect(result).to be_success
    @person_tag2 = result["tag"]
  end

  it "should retrieve single tag" do
    result = ::Tag::Operation::RetrieveTagsById.(params: { "user": "fred", ids: [@tag1.id] })
    expect(result.success?).to be_truthy
    expect(result["tags_by_id"].keys.length).to eq(1)
    expect(result["tags_by_id"][@tag1.id].name).to eq("Test Tag 1")
    expect(result["tags_by_id"][@tag1.id].tag_type).to eq("tag")
  end

  it "should retrieve multiple tags" do
    result = ::Tag::Operation::RetrieveTagsById.(params: { "user": "fred", ids: [@tag2.id, @tag1.id, @person_tag2.id] })
    expect(result.success?).to be_truthy
    expect(result["tags_by_id"].keys.length).to eq(3)
    expect(result["tags_by_id"][@tag1.id].name).to eq("Test Tag 1")
    expect(result["tags_by_id"][@tag1.id].tag_type).to eq("tag")
    expect(result["tags_by_id"][@tag2.id].name).to eq("Test Tag 2")
    expect(result["tags_by_id"][@tag2.id].tag_type).to eq("tag")
    expect(result["tags_by_id"][@person_tag2.id].name).to eq("Suzy Queue")
    expect(result["tags_by_id"][@person_tag2.id].tag_type).to eq("people")
  end

end
