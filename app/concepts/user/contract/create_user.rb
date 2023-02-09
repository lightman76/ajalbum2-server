require "reform"
require 'dry-validation'
class User::Contract::CreateUser < Reform::Form
  property :user_name

  validation name: :default do
    params do
      required(:user_name).filled
    end
  end
end
