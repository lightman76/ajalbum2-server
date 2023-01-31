require "reform"
require 'dry-validation'

class User::Contract::CreatePassword < Reform::Form
  property :user
  property :new_password

  validation name: :default do
    params do
      required(:user).filled
      required(:new_password).filled
    end
  end
end
