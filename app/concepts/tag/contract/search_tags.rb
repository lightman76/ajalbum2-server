require "reform"
module Tag::Contract
  class SearchTags < Reform::Form
    property :user
    property :search_text
    validation name: :default do
      params do
        required(:search_text).filled
        required(:user).filled
      end
    end
  end
end