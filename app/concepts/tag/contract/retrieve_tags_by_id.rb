require "reform"
module Tag::Contract
  class RetrieveTagsById < Reform::Form
    property :ids
    validation name: :default do
      params do
        required(:ids).filled
      end
    end
  end
end