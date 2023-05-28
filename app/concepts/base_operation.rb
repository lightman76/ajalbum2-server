class BaseOperation < Trailblazer::Operation

  def hydrate_user(options, model:, **)
    model.user = User.where(user_name: model.user).first if model.user.class == String
    options[:user] = model.user
    unless model.user
      add_error(options, :user, "Unknown user (1)")
      return false
    end
    true
  end

  def hydrate_user_param(options, params:, **)
    user = params[:user] || params["user"]
    key = nil
    if !user && params.keys.length > 0
      key = params.keys.first
      user = params[key][:user]
    end
    user = User.where(user_name: user).first if user.class == String
    user = User.where(id: user).first if user.class == Integer
    options[:user] = user
    unless user
      add_error(options, :user, "Unknown user (2)")
      return false
    end
    if params[:user] || params["user"]
      params[:user] = user
    end
    if key
      params[key][:user] = user
    end
    true
  end

  def validate_authorization_to_access_user(options, model:, user:, **)
    raw_token = model.authorization
    unless raw_token
      add_error(options, :authorization, "Missing authorization for this operation.")
      return false
    end

    tok_data = JWT.decode(raw_token, APP_CONFIG["jwt"]["keys"]["auth-hmac512"], true, { algorithms: ['HS512'] })
    acting_user = tok_data[0]['sub']
    unless tok_data[0]['aud'] == "AJAlbumServer" && tok_data[0]['iss'] == "AJAlbumServer"
      add_error(options, :authorization, "Invalid authorization.")
      return false
    end
    exp_date_num = tok_data[0]['exp']
    exp_time = Time.at(exp_date_num)
    unless exp_time > Time.now
      add_error(options, :authorization, "Authorization has expired.")
      return false
    end

    #OK - Token looks good
    # For now, users can only access their own albums.  In the future may add a lookup table to allow crossing between them
    unless user.user_name == tok_data[0]['sub']
      add_error(options, :authorization, "Authorization not valid for this user album.")
      return false
    end
    return true
  end

  def sync_to_model(options, model:, **)
    options["contract.default"].sync
    true
  end

  def add_error(options, field, message)
    options["contract.default"].errors.add(field, message)
  end

  def self.human_string_from_op_errors(op)
    strs = []
    details = op['contract.default'].errors.details
    details.each_key do |k|
      strs << "#{k}: #{details[k].collect { |e| e[:error] }.join(" ")}; "
    end
    return strs.join(" ")
  end

  def file_relative_path(photo, variant, original_retry_cnt)
    # NOTE: we overwrite generated images but utilize the retry count of the original
    File.join(PhotoUtils.base_path_for_photo(photo), PhotoUtils.file_name_for_photo(photo, variant: variant, retry_cnt: original_retry_cnt))
  end

end