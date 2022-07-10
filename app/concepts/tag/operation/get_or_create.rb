require_relative "../contract/get_or_create"

class Tag::Operation::GetOrCreate < ::BaseOperation
  step Model(Tag, :new)
  step Contract::Build(constant: ::Tag::Contract::GetOrCreate)
  step :process_params
  step :hydrate_user_param
  step Contract::Validate(key: :tag)
  step :find_or_create_tag

  def process_params(options, params:, **)
    options[:f] = params[:tag]
    true
  end

  def find_or_create_tag(options, f:, model:, user:, **)
    puts "Preparing to create tag #{f[:name]}"
    tag = ::Tag.where(user_id: user.id, tag_type: f[:tag_type], name: f[:name]).first
    if tag
      #found existing
      model = options[:model] = tag
    else
      #create new tag
      # TODO: ensure we don't set properties that don't make sense based on the current type (eg location shouldn't have event date, person shouldn't have location, etc)
      options[:"contract.default"].sync()
      model.save!
      tag = model
    end
    options[:tag] = tag
    true
  end

  class Endpoint < self
    def process_params(options, params:, model:, **)
      options[:f] = params[:tag]

      #Validate API access
      return false unless hydrate_user_param(options, params: params)
      params[:tag]['user'] = options[:user]
      return false unless validate_authorization_to_access_user(options, model: OpenStruct.new(authorization: params['authorization']), user: options[:user])

      true
    end

  end

end