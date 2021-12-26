require "reform"

class User::Contract::CreateUser < Reform::Form
  property :user_name

  validation do
    required(:user_name).filled
  end
end
