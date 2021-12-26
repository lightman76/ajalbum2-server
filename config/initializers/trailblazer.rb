require 'idgentable'
require 'reform/form/dry'

Rails.application.config.active_record.sqlite3 = ActiveSupport::OrderedOptions.new
Rails.application.config.reform.validations = :dry

Reform::Form.class_eval do
  feature Reform::Form::Dry
end
