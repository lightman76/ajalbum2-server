::Photo::Operation::Search.class
class Api::Photo::PhotoController < ApplicationController

  def search
    query = params
    if request.method == 'POST'
      query = JSON.parse(request.body.read)
    end
    if (result = ::Photo::Operation::Search.(params: { search: query })).success?
      out = {
        offset_date: result[:model].offset_date,
        next_offset_date: result["next_offset_date"],
        photos: ::Photo::Representer::PhotoResult.represent(result["results"].to_a).to_hash
      }
      render json: out.to_json
      return
    end
    render_api_validation_error(result, "Search failed:")
  end

  def date_outline_search
    if (result = ::Photo::Operation::DateOutlineSearch.call(params: { search: params })).success?
      out = {
        offset_date: result[:model].offset_date,
        next_offset_date: result["next_offset_date"],
        result_count_by_date: result["result_count_by_date"]
      }
      render json: out.to_json
      return
    end
    render_api_validation_error(result, "Search failed:")
  end

  def update_photos
    update_params = JSON.parse(request.body.read)
    update_params['authorization'] = request.headers['Authorization'] ? request.headers['Authorization'].sub("Bearer ", "") : nil
    update_params['user'] = params[:user]
    op = ::Photo::Operation::EditPhotoDetails.(params: update_params)
    if op.success?
      render json: { update_count: op["update_cnt"] }.to_json
      return
    end
    render_api_validation_error(op, "Update failed:")
  end

  def transfer_photos_to_user
    transfer_params = JSON.parse(request.body.read)
    transfer_params['authorization'] = request.headers['Authorization'] ? request.headers['Authorization'].sub("Bearer ", "") : nil
    transfer_params['user'] = params[:user]
    op = ::Photo::Operation::TransferPhotosToUser.(params: transfer_params)
    if op.success?
      render json: { transfer_count: op["transfer_count"] }.to_json
      return
    end
    render_api_validation_error(op, "Transfer failed:")
  end

  def delete_photos
    delete_params = {}
    delete_params['authorization'] = request.headers['Authorization'] ? request.headers['Authorization'].sub("Bearer ", "") : nil
    delete_params['user'] = params[:user]
    delete_params['photo_time_ids'] = (params[:photo_time_ids] || "").split(',').collect { |s_id| s_id.to_i }
    op = ::Photo::Operation::DeletePhotos.(params: delete_params)
    if op.success?
      render json: { delete_count: op["delete_count"] }.to_json
      return
    end
    render_api_validation_error(op, "Delete failed:")
  end
end