require "jwt"

class User::Operation::CreateUserToken < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::User::Contract::CreateUserToken)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user
  step :create_jwt

  def create_jwt(options, user:, **)
    issue_time = DateTime.now
    payload = {
      iat: issue_time.utc.to_i,
      token_val: SecureRandom.base64(32),
      sub: user.username,
      exp: (issue_time + 7.days).utc.to_i,
      aud: 'AJAlbumServer',
      iss: 'AJAlbumServer'
    }
    options[:token] = ::JWT.encode(payload, APP_CONFIG["jwt"]["keys"]["auth-hmac512"], 'HS512')

    return true
  end
end