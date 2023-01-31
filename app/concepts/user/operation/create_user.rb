class User::Operation::CreateUser < ::BaseOperation
  step Model(User, :new)
  step Contract::Build(constant: ::User::Contract::CreateUser)
  step Contract::Validate(key: :user)
  step :sync_to_model
  step :save_model

  def save_model(options, model:, **)
    model.save!
    options[:user] = model
    true
  end

end

#