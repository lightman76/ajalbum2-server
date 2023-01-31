module Api
  module Tag
    class TagController < ApplicationController

      def tags_by_id
        query = params
        if request.method == 'POST'
          query = JSON.parse(request.body.read)
        end
        if (result = ::Tag::Operation::RetrieveTagsById.(params: { ids: query })).success?
          render json: { tags: result["tags_by_id"] }.to_json
          return
        end
        render_api_validation_error(result, "Tag retrieval failed:")
      end

      def search_tags
        if result = ::Tag::Operation::SearchTags.(params: { search: { user: params[:user_name], search_text: params[:search_text] } })
          render json: { matching_tags: result["matching_tags"] }.to_json
          return
        end
        render_api_validation_error(result, "Tag retrieval failed:")
      end

    end
  end
end
