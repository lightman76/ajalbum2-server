require "reform"
require 'dry-validation'

class User::Contract::ExchangePasswordForToken < Reform::Form
  property :user
  property :password

  validation name: :default do
    params do
      required(:user).filled
      required(:password).filled
    end
  end
end
