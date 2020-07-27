require_relative "../contract/search"

class Photo::Operation::DateOutlineSearch < Trailblazer::Operation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::DateOutlineSearch)
  step Contract::Validate(key: :search)
  step :sync_to_model
  step :extra_sanity_checks
  step :process_date_params
  step :search!

  def extra_sanity_checks(options, model:, **)
    model.offset_date = AJUtils.parse_dashed_date_eod(model.offset_date) if model.offset_date.class == String
    model.offset_date = model.end_date unless model.offset_date
    model.offset_date = DateTime.now unless model.offset_date

    model.max_days_results = 100 if model.max_days_results.nil? || model.max_days_results > ::Photo::Contract::DateOutlineSearch::MAX_DAY_RESULTS
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
    query_chain = ::Photo.group('date(time)')
    query_chain = query_chain.where(["MATCH(title, description, location_name) AGAINST (?)", model.search_text]) if model.search_text
    query_chain = query_chain.where(["time >= ?", model.start_date]) if model.start_date
    query_chain = query_chain.where(["time < ?", model.offset_date]) #always use offset date
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
    query_chain = query_chain.limit(model.max_days_results)
    results_by_date_hash = query_chain.count(:id)

    results_by_date = []
    results_by_date_hash.each_pair do |d, cnt|
      results_by_date << {date: sprintf("%04d-%02d-%02d", d.year, d.month, d.day), num_items: cnt}
    end

    results_by_date = results_by_date.sort { |a, b| b[:date] <=> a[:date] } #reverse date sort new->old
    options["result_count_by_date"] = results_by_date
    true
  end

  def json_response
    options["result_count_by_date"].to_json
  end


end