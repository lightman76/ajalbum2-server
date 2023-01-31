require 'rails_helper'
#
RSpec.describe ::User::Operation::CreateUserToken do
  before :each do
    op = ::User::Operation::CreateUser.(params: { user: { username: "fred" } })
    expect(op.success?).to be_truthy
    @user = op["user"]
    op = ::User::Operation::CreatePassword.(params: { user: 'fred', new_password: "Asdf1234" })
    expect(op.success?).to be_truthy
  end

  it "should generate valid jwt" do
    op = ::User::Operation::CreateUserToken.(params: { user: 'fred' })
    expect(op.success?).to be_truthy
    expect(op["token"]).not_to be_nil
    raw_token = op["token"]
    tok_data = JWT.decode(raw_token, APP_CONFIG["jwt"]["keys"]["auth-hmac512"], true, { algorithms: ['HS512'] })
    expect(tok_data.length).to eq(2)
    expect(tok_data[0]['sub']).to eq("fred")
    expect(tok_data[0]['aud']).to eq("AJAlbumServer")
    expect(tok_data[0]['iss']).to eq("AJAlbumServer")
    expect(tok_data[0]['token_val']).not_to be_nil
  end

end
