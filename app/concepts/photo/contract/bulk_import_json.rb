require "reform"


module Photo::Contract
  class BulkImportJson < Reform::Form
    property :user
    property :json_data
    property :skip_autorotate, virtual: true
    property :import_photo_root

    validation name: :default do
      params do
        required(:user).filled
        required(:json_data).filled
        required(:import_photo_root).filled
      end
    end

  end
end
