class AJUtils
  def self.parse_dashed_date_eod(d_str)
    #parse the date in the server timezone
    return DateTime.iso8601("#{d_str}T23:59:59#{APP_CONFIG["defaults"]["timezone_offset_str"]}")
  rescue
    return nil
  end
end