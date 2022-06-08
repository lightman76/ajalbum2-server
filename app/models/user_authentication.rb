class UserAuthentication < ApplicationRecord
  belongs_to :user

  AUTH_TYPE__BCRYPT = 0

  store :authentication_data, coder: JSON

end