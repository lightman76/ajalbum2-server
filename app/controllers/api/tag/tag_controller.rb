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
        result = ::Tag::Operation::SearchTags.(params: { search: { user: params[:user_name], search_text: params[:search_text] } })
        if result.success?
          render json: { matching_tags: result["matching_tags"] }.to_json
          return
        end
        render_api_validation_error(result, "Tag search failed:")
      end

      def retrieve_all_tags
        result = ::Tag::Operation::RetrieveAllTags.(params: { user: params[:user_name] })
        if result.success?
          render json: { all_tags: result["all_tags"] }.to_json
          return
        end
        render_api_validation_error(result, "Tag retrieval failed:")
      end

      def create_tag
        create_params = {}
        create_params[:tag] = JSON.parse(request.body.read)
        create_params[:tag]['user'] = params[:user_name]
        create_params[:user] = params[:user_name]
        create_params['authorization'] = request.headers['Authorization'] ? request.headers['Authorization'].sub("Bearer ", "") : nil
        op = ::Tag::Operation::GetOrCreate::Endpoint.(params: create_params)
        if op.success?
          render json: { tag: op[:tag] }.to_json
          return
        end

        render_api_validation_error(op, "Tag creation failed:")
      end

    end
  end
end
