require_relative "../contract/retrieve_all_tags"

class Tag::Operation::RetrieveAllTags < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Tag::Contract::RetrieveAllTags)
  step Contract::Validate()
  step :hydrate_user_param
  step :sync_to_model
  step :retrieve_tags

  def retrieve_tags(options, model:, user:, **)
    tags = Tag.where(user_id: user.id).all
    options[:all_tags] = tags
    return true
  end

end