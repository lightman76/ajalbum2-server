require_relative "../contract/create"

class ::Source::Create < Trailblazer::Operation
  step Model(::Source, :new)
  step Contract::Build(constant: ::Source::Contract::Create)
  step :hydrate_user_param
  step Contract::Validate(key: :source)
  step Contract::Persist()

end