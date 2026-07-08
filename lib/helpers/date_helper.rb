module DateHelper
  
  # @param date [Date]
  # @return [Date]
  def self.make_monday(date)
    days_since_monday = (date.wday - 1) % 7
    date - days_since_monday
  end

end