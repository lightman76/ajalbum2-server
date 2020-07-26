require "reform"
require "reform/form/dry"


module Photo::Contract
  class GenerateImages < Reform::Form
    include Dry

    property :photo_model
    property :autorotate, virtual: true

    validation do
      required(:photo_model).filled
    end

  end
end
