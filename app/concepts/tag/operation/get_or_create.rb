require_relative "../contract/get_or_create"

class Tag::GetOrCreate < ::BaseOperation
  step Model(Tag, :new)
  step Contract::Build(constant: ::Tag::Contract::GetOrCreate)
  step Contract::Validate(key: :tag)
  step :process_params
  step :hydrate_user_param
  step :find_or_create_tag

  def process_params(options, params:, **)
    options[:f] = params[:tag]
    true
  end

  def find_or_create_tag(options, f:, model:, user:, **)
    tag = ::Tag.where(user_id: user.id, tag_type: f[:tag_type], name: f[:name]).first
    if tag
      #found existing
      model = options[:model] = tag
    else
      #create new tag
      # TODO: ensure we don't set properties that don't make sense based on the current type (eg location shouldn't have event date, person shouldn't have location, etc)
      options["contract.default"].sync()
      model.save!
      tag = model
    end
    options[:tag] = tag
    true
  end


end