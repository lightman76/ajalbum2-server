class BaseOperation < Trailblazer::Operation

  def sync_to_model(options, model:, **)
    options["contract.default"].sync
    true
  end

end