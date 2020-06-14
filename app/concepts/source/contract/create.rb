require "reform"
require "reform/form/dry"


module Source::Contract
  class Create < Reform::Form
    include Dry

    property :raw_name, default: "unknown"
    property :display_name, default: "Unknown"

    validation do
      required(:raw_name).filled
      required(:display_name).filled
    end

  end
end
