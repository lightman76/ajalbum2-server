require_relative "../contract/create"

class ::Source::Create < ::BaseOperation
  step Model(::Source, :new)
  step Contract::Build(constant: ::Source::Contract::Create)
  step :hydrate_user_param
  step Contract::Validate()
  step Contract::Persist()

end