class User::Operation::CreatePassword < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::User::Contract::CreatePassword)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user
  step :validate_password_strength
  step :save_authentication

  def validate_password_strength(options, model:, **)
    if model.new_password.length < 8
      add_error(options, :new_password, "Must be at least 8 characters long")
      return false
    end
    unless /[0-9]/.match(model.new_password)
      add_error(options, :new_password, "Must contain a number")
      return false
    end
    unless /[a-z]/.match(model.new_password)
      add_error(options, :new_password, "Must contain a lower case letter")
      return false
    end
    unless /[A-Z]/.match(model.new_password)
      add_error(options, :new_password, "Must contain an upper case letter")
      return false
    end

    return true
  end

  def save_authentication(options, model:, user:, **)
    auth = UserAuthentication.where(user_id: user.id, auth_type: ::UserAuthentication::AUTH_TYPE__BCRYPT).first
    unless auth
      auth = UserAuthentication.new(user_id: user.id, auth_type: ::UserAuthentication::AUTH_TYPE__BCRYPT)
    end
    auth.authentication_data["bcrypt_hash"] = BCrypt::Password.create(model.new_password).to_s
    auth.save!
    options[:user_authentication] = auth
    return true
  end
end