require_relative "../contract/search_tags"

class Tag::Operation::SearchTags < BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Tag::Contract::SearchTags)
  step Contract::Validate(key: :search)
  step :sync_to_model
  step :retrieve_tags

  def retrieve_tags(options, model:, **)
    tags = Tag.where("name like ?", "%#{model.search_text}%").limit(100).all
    options[:matching_tags] = tags
    return true
  end

end