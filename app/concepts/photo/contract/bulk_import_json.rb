require "reform"


module Photo::Contract
  class BulkImportJson < Reform::Form
    property :json_data

    validation do
      required(:json_data).filled
    end

  end
end
