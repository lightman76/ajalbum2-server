require "reform"
module Tag::Contract
  class RetrieveTagsById < Reform::Form
    property :ids
    validation do
      required(:ids).filled
    end
  end
end