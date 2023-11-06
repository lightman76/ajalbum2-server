require_relative "../contract/search"

class Photo::Operation::Search < ::BaseOperation
  step Model(OpenStruct, :new)
  step Contract::Build(constant: ::Photo::Contract::Search)
  step Contract::Validate(key: :search)
  step :sync_to_model
  step :hydrate_user
  step :process_date_params
  step :process_paging_params
  step :search!

  def process_paging_params(options, model:, **)
    model.offset_date = AJUtils.parse_dashed_date_as_int(model.offset_date) if model.offset_date.class == String
    model.offset_date = model.offset_date.strftime("%Y%m%d").to_i if model.offset_date.class == DateTime
    model.offset_date = model.end_date unless model.offset_date
    model.offset_date = DateTime.now.strftime("%Y%m%d").to_i unless model.offset_date

    model.target_max_results = model.target_max_results.to_i if model.target_max_results && model.target_max_results.class == String
    model.target_max_results = 250 if model.target_max_results.nil? || model.target_max_results > ::Photo::Contract::Search::MAX_TARGET_MAX_RESULTS
    true
  end

  def process_date_params(options, model:, **)
    if model.start_date
      # model.start_date = DateTime.iso8601(model.start_date)
      model.start_date = AJUtils.parse_dashed_date_as_int(model.start_date)
    end
    if model.end_date
      # model.end_date = DateTime.iso8601(model.end_date)
      model.end_date = AJUtils.parse_dashed_date_as_int(model.end_date)
    end
    model.timezone_offset_min = nil unless model.timezone_offset_min.class == Integer
    if model.timezone_offset_min
      #TODO: cache this somehow?
      time_zone = ActiveSupport::TimeZone.all.detect do |zone|
        zone.now.utc_offset == model.timezone_offset_min * 60
      end
      Time.zone = time_zone
    end
    true
  end

  def sync_to_model(options, model:, **)
    options["contract.default"].sync
    true
  end

  def search!(options, model:, user:, **)
    query_chain = ::Photo
    query_chain = query_chain.where(["MATCH(title, description, location_name) AGAINST (?)", model.search_text]) if model.search_text
    query_chain = query_chain.where(user_id: user.id)
    query_chain = query_chain.where(["date_bucket >= ?", model.start_date]) if model.start_date
    query_chain = query_chain.where(["date_bucket <= ?", model.offset_date]) # always use offset date
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
    query_chain = query_chain.order(time_id: :desc)
    query_chain = query_chain.limit(model.target_max_results)
    options["results"] = query_chain.all.to_a
    options["next_offset_date"] = nil
    last_result = options["results"].last
    if last_result
      # now make sure we have ALL matches for this earliest day of the result set
      last_result_date_bucket = last_result.date_bucket
      options["next_offset_date"] = bucket_before(last_result_date_bucket)
      if model.start_date.nil? || last_result_date_bucket
        query_chain = ::Photo
        query_chain = query_chain.where(user_id: user.id)
        query_chain = query_chain.where(["MATCH(title, description, location_name) AGAINST (?)", model.search_text]) if model.search_text
        query_chain = query_chain.where(["date_bucket = ?", last_result_date_bucket])
        query_chain = query_chain.where(["photos.time_id < ?", last_result.time_id])
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
        query_chain = query_chain.order("photos.time_id" => :desc)
        partial_day_results = query_chain.all.to_a
        options["results"] = options["results"] + partial_day_results
      end
    end

    true
  end

  def bucket_before(bucket)
    s = bucket.to_s
    d = DateTime.new(s[0...4].to_i, s[4...6].to_i, s[6...8].to_i)
    d = d - 1.day
    d.strftime("%Y%m%d").to_i
  rescue StandardError => e
    Rails.logger.warn("Invalid date bucket: '#{bucket}' - #{e.message}")
    nil
  end
end