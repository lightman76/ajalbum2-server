require_relative "../contract/search"

class Photo::Search < Trailblazer::Operation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::Search)
  step Contract::Validate(key: :search)
  step :extra_sanity_checks
  step :process_date_params
  step :search!

  def extra_sanity_checks(options, model:, **)
    model.page = 0 if model.page < 0
    model.results_per_page = 100 if model.results_per_page > ::Photo::Contract::Search::MAX_RESULTS_PER_PAGE
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

  def search!(options, model:, **)
    query_chain = Photo
    query_chain.where(["MATCH(title, description, location_name) AGAINST ?", model.search_text]) if model.search_text
    query_chain.where(["time >= ?", model.start_date]) if model.start_date
    query_chain.where(["time < ?", model.end_date]) if model.end_date
    query_chain.order(time: :asc) unless model.search_text #for full text search don't specify order
    query_chain.limit(model.results_per_page)
    query_chain.offset(model.page * model.results_per_page)
    #TODO: add tags
    options["results"] = query_chain.all
    true
  end


end