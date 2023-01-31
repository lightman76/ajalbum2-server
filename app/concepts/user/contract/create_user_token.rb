require "reform"
require 'dry-validation'

class User::Contract::CreateUserToken < Reform::Form
  property :user

  validation name: :default do
    params do
      required(:user).filled
    end
  end
end
