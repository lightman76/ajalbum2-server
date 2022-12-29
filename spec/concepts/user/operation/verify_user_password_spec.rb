require 'rails_helper'
#
RSpec.describe ::User::Operation::VerifyUserPassword do
  before :each do
    op = ::User::Operation::CreateUser.(params: { user: { user_name: "fred" } })
    expect(op.success?).to be_truthy
    @user = op["user"]
    op = ::User::Operation::CreatePassword.(params: { user: 'fred', new_password: "Asdf1234" })
    expect(op.success?).to be_truthy
  end

  it "should verify the correct password" do
    op = ::User::Operation::VerifyUserPassword.(params: { user: 'fred', password: "Asdf1234" })
    expect(op.success?).to be_truthy
    expect(op["user_authentication"]).not_to be_nil
  end

  it "should fail to verify the incorrect password" do
    op = ::User::Operation::VerifyUserPassword.(params: { user: 'fred', password: "aSdf1234" })
    expect(op.success?).to be_falsey
  end

end #
