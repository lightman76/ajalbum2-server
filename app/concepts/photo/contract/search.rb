require "reform"


module Photo::Contract
  class Search < Reform::Form
    MAX_TARGET_MAX_RESULTS = 500

    property :search_text
    property :start_date #ISO date - this is the general search date limit
    property :end_date #ISO date - this is the general search date limit
    property :min_threshold #integer
    property :max_threshold #integer
    property :tags #array of tag ids

    #Going to use weird pagination to make it easier to work with the date_outline_search
    #
    # If we return ANY results for a given DAY, we'll return ALL results for that day.  This should also
    # make it easier to jump around to a specific point in time.
    # We'll go back and return results from before "offset_date" return all photos for each day up until we reach "target_max_results"
    # We'll add additional results to make sure we include all the results for the last day being returned,
    # even if that takes us over "target_max_results"
    #
    # So this could return photos for 1 day or 1 year depending on the distribution of the photos.
    #
    property :offset_date #instead of "page number" for pagination, defaults to end_date or today
    property :target_max_results

  end
end
