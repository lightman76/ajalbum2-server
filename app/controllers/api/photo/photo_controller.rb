::Photo::Operation::Search.class
module Api
  module Photo
    class PhotoController < ApplicationController

      def search
        query = params
        if request.method == 'POST'
          query = JSON.parse(request.body.read)
        end
        if (result = ::Photo::Operation::Search.(params: {search: query})).success?
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
        if (result = ::Photo::Operation::DateOutlineSearch.call(params: {search: params})).success?
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

    end
  end
end