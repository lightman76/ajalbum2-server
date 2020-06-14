require 'rails_helper'

RSpec.describe Photo::Create do
  before :each do
    op = ::Source::Create.(params: {source: {raw_name: 'unknown', display_name: 'Unknown'}})
    expect(op).to be_success
  end

  it "should create a photo record" do
    t = DateTime.now
    params = {"photo": {"image_stream": 1, "time": t, "title": "Test Photo", source_name: 'unknown'}}
    result = ::Photo::Create.(params: params)
    expect(result).to be_success
    expect(result["model"]).not_to be_nil
  end
end