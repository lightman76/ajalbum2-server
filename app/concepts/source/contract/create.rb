require "reform"
require "reform/form/dry"


module Source::Contract
  class Create < Reform::Form
    include Dry

    property :user
    property :raw_name, default: "unknown"
    property :display_name, default: "Unknown"

    validation name: :default do
      params do
        required(:user).filled
        required(:raw_name).filled
        required(:display_name).filled
      end
    end

  end
end
