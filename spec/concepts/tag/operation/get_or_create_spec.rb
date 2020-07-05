require 'rails_helper'

RSpec.describe Tag::GetOrCreate do

  it "should create new tag tag" do
    params = {"tag": {"tag_type": "tag", "name": "Test Tag 1"}}
    result = ::Tag::GetOrCreate.(params: params)
    expect(result).to be_success
    expect(result["tag"]).not_to be_nil
    expect(result["tag"].name).to eq("Test Tag 1")
    expect(result["tag"].tag_type).to eq("tag")
    expect(result["tag"]).to eq(result["model"])
  end

  it "should find existing tag" do
    params = {"tag": {"tag_type": "tag", "name": "Test Tag 1"}}
    result = ::Tag::GetOrCreate.(params: params)
    expect(result).to be_success
    tag1 = result["tag"]
    expect(Tag.count).to eq(1)
    result2 = ::Tag::GetOrCreate.(params: params)
    expect(result2).to be_success
    expect(Tag.count).to eq(1)
    tag2 = result2["tag"]
    expect(tag1.id).to eq(tag2.id)
  end

end
