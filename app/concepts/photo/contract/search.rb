require "reform"


module Photo::Contract
  class Search < Reform::Form
    MAX_RESULTS_PER_PAGE = 500

    property :search_text
    property :start_date #ISO date
    property :end_date #ISO date
    property :min_threshold #integer
    property :max_threshold #integer
    property :tags #array of tag ids
    property :page #0 based page num - default 0
    property :results_per_page #min 1 max 500

  end
end
