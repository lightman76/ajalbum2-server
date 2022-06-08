class Api::User::UserController < ApplicationController
  def authenticate
    query = params
    if request.method == 'POST'
      query = JSON.parse(request.body.read)
    end
    query['user'] = params[:user_name]
    op = ::User::Operation::ExchangePasswordForToken.(params: { user: query['user'], password: query['password'] })
    if op.success?
      render json: { token: op[:token] }.to_json
      return
    end
    render_api_validation_error(result, "User authentication failed. ")
  end

end
