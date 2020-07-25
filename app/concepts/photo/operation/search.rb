require_relative "../contract/search"

class Photo::Operation::Search < Trailblazer::Operation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::Search)
  step Contract::Validate(key: :search)
  step :sync_to_model
  step :extra_sanity_checks
  step :process_date_params
  step :search!

  def extra_sanity_checks(options, model:, **)
    model.page = model.page.to_i if model.page && model.page.class == String
    model.page = 0 if model.page.nil? || model.page < 0
    model.results_per_page = model.results_per_page.to_i if model.results_per_page && model.results_per_page.class == String
    model.results_per_page = 100 if model.results_per_page.nil? || model.results_per_page > ::Photo::Contract::Search::MAX_RESULTS_PER_PAGE
    true
  end

  def process_date_params(options, model:, **)
    if model.start_date
      model.start_date = DateTime.iso8601(model.start_date)
    end
    if model.end_date
      model.end_date = DateTime.iso8601(model.end_date)
    end
    true
  end

  def sync_to_model(options, model:, **)
    options["contract.default"].sync
    true
  end

  def search!(options, model:, **)
    query_chain = ::Photo
    query_chain = query_chain.where(["MATCH(title, description, location_name) AGAINST (?)", model.search_text]) if model.search_text
    query_chain = query_chain.where(["time >= ?", model.start_date]) if model.start_date
    query_chain = query_chain.where(["time < ?", model.end_date]) if model.end_date
    query_chain = query_chain.where(["feature_threshold >= ?", model.min_threshold]) if model.min_threshold
    query_chain = query_chain.where(["feature_threshold <= ?", model.max_threshold]) if model.max_threshold
    if model.tags && model.tags.length > 0
      tag_cnt = 0
      model.tags.each do |tag_id|
        tag_id = tag_id.to_i if tag_id.class == String
        if tag_id
          query_chain = query_chain.joins("INNER JOIN photo_tags t#{tag_cnt} on photos.id=t#{tag_cnt}.photo_id")
                            .where(["t#{tag_cnt}.tag_id=?", tag_id])
        end
        tag_cnt += 1
      end
    end
    query_chain = query_chain.order(time: :desc)
    query_chain = query_chain.limit(model.results_per_page)
    query_chain = query_chain.offset(model.page * model.results_per_page)
    options["results"] = query_chain.all
    true
  end

end