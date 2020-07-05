require_relative "../contract/bulk_import_json"

class Photo::BulkImportJson < Trailblazer::Operation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::BulkImportJson)
  step Contract::Validate()
  step :get_json_data
  step :process_json

  def get_json_data(options, params:, **)
    options[:json_data] = params[:json_data]
    true
  end

  def process_json(options, json_data:, **) end


end