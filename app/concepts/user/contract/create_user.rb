require "reform"
require 'dry-validation'
class User::Contract::CreateUser < Reform::Form
  property :username

  validation name: :default do
    params do
      required(:username).filled
    end
  end
end