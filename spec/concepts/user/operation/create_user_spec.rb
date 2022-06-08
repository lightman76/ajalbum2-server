require 'rails_helper'

RSpec.describe ::User::Operation::CreateUser do

  it "should create new user" do
    op = ::User::Operation::CreateUser.(params: { user: { username: "fred" } })
    expect(op.success?).to be_truthy
    expect(op["user"]).not_to be_nil
    expect(op["user"].username).to eq("fred")
  end

end #
