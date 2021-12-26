require "reform"


module Photo::Contract
  class DateOutlineSearch < Reform::Form
    MAX_DAY_RESULTS = 365 * 2

    property :user
    property :search_text
    property :start_date #ISO date - this is the general search date limit
    property :end_date #ISO date - this is the general search date limit
    property :min_threshold #integer
    property :max_threshold #integer
    property :tags #array of tag ids

    #Offset date is used to start the window of the most recent date to return results and will query towards start_date up to max_day_results
    property :offset_date #instead of "page number" for pagination, defaults to end_date or today
    property :max_days_results #maximum number of days to return (NOTE: this is not calendar days, this is days with photos matching criteria)
    property :timezone_offset_min #timezone offset minutes of the client

  end
end
