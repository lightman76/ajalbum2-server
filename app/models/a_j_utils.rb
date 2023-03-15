class AJUtils
  def self.parse_dashed_date_eod(d_str)
    parts = d_str.split("-")
    padded_str = sprintf("%04d-%02d-%02d", parts[0], parts[1], parts[2])
    # parse the date in the server timezone
    return DateTime.iso8601("#{padded_str}T23:59:59#{APP_CONFIG["defaults"]["timezone_offset_str"]}")
  rescue
    return nil
  end

  def self.parse_dashed_date_as_int(d_str)
    parts = d_str.split("-")
    return sprintf("%04d%02d%02d", parts[0], parts[1], parts[2]).to_i
  rescue
    return nil
  end
end