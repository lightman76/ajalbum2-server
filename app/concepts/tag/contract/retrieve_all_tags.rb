require "reform"

class Tag::Contract::RetrieveAllTags < Reform::Form
  property :user
  validation name: :default do
    params do
      required(:user).filled
    end
  end
end