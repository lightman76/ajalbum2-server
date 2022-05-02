class ApplicationController < ActionController::API

  def render_api_validation_error(models, message)
    models = [models].flatten
    error_messages = []
    model_errors = {}
    models.each do |m|
      if m.respond_to? :errors
        m.errors.details.each_pair do |k, v|
          model_errors[k] = []
          v.each { |err| error_messages << "#{k.to_s.humanize} #{err[:error].to_s.humanize}"; model_errors[k] << err[:error].to_s.humanize }
        end
      elsif m['contract.default'] && m['contract.default'].errors
        error_messages << m['contract.default'].errors.full_messages
      end
    end
    Rails.logger.error("API Request validation failure: #{request.original_url}: " + {:status => 'failure', :_api_status_code => 422, :message => "#{message} #{error_messages.join('; ')}", errors: model_errors}.to_json)
    render :json => {:status => 'failure', :_api_status_code => 422, :message => "#{message} #{error_messages.join('; ')}", errors: model_errors}.to_json, :status => 422
  end

end
