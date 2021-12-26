class BaseOperation < Trailblazer::Operation

  def hydrate_user(options, model:, **)
    model.user = User.where(user_name: model.user).first if model.user.class == String
    options[:user] = model.user
    unless model.user
      add_error(options, :user, "Unknown user")
      return false
    end
    true
  end

  def hydrate_user_param(options, params:, **)
    params[:user] = User.where(user_name: params[:user]).first if params[:user].class == String
    params[:user] = User.where(id: params[:user]).first if params[:user].class == Integer
    options[:user] = params[:user]
    unless params[:user]
      add_error(options, :user, "Unknown user")
      return false
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