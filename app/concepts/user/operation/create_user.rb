class User::Operation::CreateUser < ::BaseOperation
  step Model(User, :new)
  step Contract::Build(constant: ::User::Contract::CreateUser)
  step Contract::Validate(key: :user)
  step :sync_to_model
  step :save_model
  step :create_directories

  def save_model(options, model:, **)
    model.save!
    options[:user] = model
    true
  end

  def create_directories(options, user:, **)
    FileUtils.mkdir_p(PhotoUtils.originals_path(user.id))
    FileUtils.mkdir_p(PhotoUtils.generated_images_path(user.id))
    true
  end

end

#