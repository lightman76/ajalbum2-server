require 'rails_helper'

RSpec.describe ::User::Operation::CreateUser do

  it "should create new user" do
    op = ::User::Operation::CreateUser.(params: { user: { user_name: "fred" } })
    expect(op.success?).to be_truthy
    expect(op["user"]).not_to be_nil
    expect(op["user"].user_name).to eq("fred")
  end

end
