class BaseOperation < Trailblazer::Operation

  def hydrate_user(options, model:, **)
    model.user = User.where(username: model.user).first if model.user.class == String
    options[:user] = model.user
    unless model.user
      add_error(options, :user, "Unknown user")
      return false
    end
    true
  end

  def hydrate_user_param(options, params:, **)
    user = params[:user]
    key = nil
    if !user && params.keys.length > 0
      key = params.keys.first
      user = params[key][:user]
    end
    user = User.where(username: user).first if user.class == String
    user = User.where(id: user).first if user.class == Integer
    options[:user] = user
    unless user
      add_error(options, :user, "Unknown user")
      return false
    end
    if params[:user]
      params[:user] = user
    end
    if key
      params[key][:user] = user
    end
    true
  end

  def sync_to_model(options, model:, **)
    options["contract.default"].sync
    true
  end

  def add_error(options, field, message)
    options["contract.default"].errors.add(field, message)
  end

end