::Photo::Operation::Search.class
module Api
  module Photo
    class PhotoController < ApplicationController

      def search
        if (result = ::Photo::Operation::Search.(params: {search: params})).success?
          render json: ::Photo::Representer::PhotoResult.represent(result["results"].to_a).to_json
          return
        end
        render_api_validation_error(result, "Search failed:")
      end

      def date_outline_search
        if (result = ::Photo::Operation::DateOutlineSearch.call(params: {search: params})).success?
          render json: result["result_count_by_date"].to_json
          return
        end
        render_api_validation_error(result, "Search failed:")
      end

    end
  end
end