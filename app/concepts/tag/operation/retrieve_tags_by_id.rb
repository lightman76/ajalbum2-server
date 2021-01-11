require_relative "../contract/retrieve_tags_by_id"

class Tag::Operation::RetrieveTagsById < BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Tag::Contract::RetrieveTagsById)
  step Contract::Validate()
  step :sync_to_model
  step :retrieve_tags

  def retrieve_tags(options, model:, **)
    options[:tags_by_id] = {}
    if model.ids && model.ids.length > 0
      tags = [Tag.get(model.ids)].flatten
      tags.each do |tag|
        options[:tags_by_id][tag.id] = tag
      end
    end
    return true
  end

end