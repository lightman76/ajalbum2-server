class User::Operation::ExchangePasswordForToken < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::User::Contract::ExchangePasswordForToken)
  step Contract::Validate()
  step :sync_to_model
  step :hydrate_user
  step :validate_password
  step :generate_token

  def validate_password(options, model:, user:, **)
    op = ::User::Operation::VerifyUserPassword.(params: { user: user, password: model.password })
    unless op.success?
      add_error(options, :password, "Invalid username or password")
      return false
    end
    true
  end

  def generate_token(options, model:, user:, **)
    op = ::User::Operation::CreateUserToken.(params: { user: user })
    unless op.success?
      add_error(options, :messages, "An error occurred while generating the authentication token")
      return false
    end
    options[:token] = op["token"]

    true
  end

end