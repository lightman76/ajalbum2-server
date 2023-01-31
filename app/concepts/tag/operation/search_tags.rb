require_relative "../contract/search_tags"

class Tag::Operation::SearchTags < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Tag::Contract::SearchTags)
  step Contract::Validate(key: :search)
  step :hydrate_user_param
  step :sync_to_model
  step :retrieve_tags

  def retrieve_tags(options, model:, user:, **)
    tags = Tag.where(user_id: user.id).where("name like ?", "%#{model.search_text}%").limit(100).all
    options[:matching_tags] = tags
    return true
  end

end