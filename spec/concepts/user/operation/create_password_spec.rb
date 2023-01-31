require 'rails_helper'
#
RSpec.describe ::User::Operation::CreatePassword do
  before :each do
    op = ::User::Operation::CreateUser.(params: { user: { username: "fred" } })
    expect(op.success?).to be_truthy
    @user = op["user"]
  end

  it "should create password for user" do
    op = ::User::Operation::CreatePassword.(params: { user: 'fred', new_password: "Asdf1234" })
    expect(op.success?).to be_truthy
    expect(op["user_authentication"]).not_to be_nil
    auth = op["user_authentication"]
    auth.reload
    expect(auth.user_id).to eq(@user.id)
    expect(auth.auth_type).to eq(::UserAuthentication::AUTH_TYPE__BCRYPT)
    expect(auth.authentication_data["bcrypt_hash"]).not_to be_nil
    expect(::BCrypt::Password.new(auth.authentication_data["bcrypt_hash"]) == "Asdf1234")
  end

end #
