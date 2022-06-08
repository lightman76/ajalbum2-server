class User::Operation::VerifyUserPassword < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::User::Contract::VerifyUserPassword)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user
  step :validate_password

  def validate_password(options, model:, user:, **)
    auths = UserAuthentication.where(user_id: user.id, auth_type: ::UserAuthentication::AUTH_TYPE__BCRYPT).all
    accepted_auth = auths.detect do |auth|
      bcrypt_hash = auth.authentication_data["bcrypt_hash"]
      bcrypt_pass = BCrypt::Password.new(bcrypt_hash)
      bcrypt_pass == model.password
    end

    unless accepted_auth
      add_error(options, :password, "Invalid username or password")
      return false
    end
    options[:user_authentication] = accepted_auth
    return true
  end

end