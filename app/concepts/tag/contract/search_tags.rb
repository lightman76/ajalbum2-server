require "reform"
module Tag::Contract
  class SearchTags < Reform::Form
    property :search_text
    validation do
      required(:search_text).filled
    end
  end
end