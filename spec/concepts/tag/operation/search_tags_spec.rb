require 'rails_helper'

RSpec.describe ::Tag::Operation::SearchTags do
  before :each do
    op = ::User::Operation::CreateUser.(params: { user: { username: "fred" } })
    @user = op[:user]

    params = { "tag": { "user": "fred", "tag_type": "tag", "name": "Test Tag 1" } }
    result = ::Tag::Operation::GetOrCreate.(params: params)
    expect(result).to be_success
    @tag1 = result["tag"]

    params = { "tag": { "user": "fred", "tag_type": "tag", "name": "Test Tag 2" } }
    result = ::Tag::Operation::GetOrCreate.(params: params)
    expect(result).to be_success
    @tag2 = result["tag"]

    params = { "tag": { "user": "fred", "tag_type": "people", "name": "John Doe" } }
    result = ::Tag::Operation::GetOrCreate.(params: params)
    expect(result).to be_success
    @person_tag1 = result["tag"]

    params = { "tag": { "user": "fred", "tag_type": "people", "name": "Suzy Queue" } }
    result = ::Tag::Operation::GetOrCreate.(params: params)
    expect(result).to be_success
    @person_tag2 = result["tag"]
  end

  it "should retrieve two tag tags" do
    result = ::Tag::Operation::SearchTags.(params: { search: { "user": "fred", search_text: 'Test' } })
    expect(result.success?).to be_truthy
    expect(result["matching_tags"].length).to eq(2)
    expect(result["matching_tags"][0].name).to eq("Test Tag 1")
    expect(result["matching_tags"][0].tag_type).to eq("tag")
    expect(result["matching_tags"][1].name).to eq("Test Tag 2")
    expect(result["matching_tags"][1].tag_type).to eq("tag")
  end

  it "should retrieve four tags" do
    result = ::Tag::Operation::SearchTags.(params: { search: { "user": "fred", search_text: 'e' } })
    expect(result.success?).to be_truthy
    expect(result["matching_tags"].length).to eq(4)
    expect(result["matching_tags"][0].name).to eq("Test Tag 1")
    expect(result["matching_tags"][1].name).to eq("Test Tag 2")
    expect(result["matching_tags"][2].name).to eq("John Doe")
    expect(result["matching_tags"][3].name).to eq("Suzy Queue")
  end
end