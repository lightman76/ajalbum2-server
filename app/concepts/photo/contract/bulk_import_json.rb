require "reform"


module Photo::Contract
  class BulkImportJson < Reform::Form
    property :json_data
    property :skip_autorotate, virtual: true
    property :import_photo_root

    validation do
      required(:json_data).filled
      required(:import_photo_root).filled
    end

  end
end
