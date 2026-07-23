require_relative "date_helper"

class PeriodDefiner

  # @param date [String]
  def self.define_week(date)
    raise ArgumentError, "Date cannot be nil" unless date
    stripped = date.strip.downcase
    case stripped
    when "thisweek", "tweek", "tw"
      DateHelper::Weeks.this_week
    when "lastweek", "lweek", "lw"
      DateHelper::Weeks.last_week
    else 
      DateHelper.parse_arg(stripped)
    end
  end

  # @param date [String]
  def self.define_day(date)
    raise ArgumentError, "Date cannot be nil" unless date
    stripped = date.strip.downcase
    case stripped
    when "today", "tod", "td"
      DateHelper::Weeks.today
    when "yesterday", "yes"
      DateHelper::Weeks.yesterday
    when "friday", "fri", "tfri"
      DateHelper::Weeks.friday
    when "saturday", "sat", "tsat"
      DateHelper::Weeks.saturday
    when "sunday", "sun", "tsun"
      DateHelper::Weeks.sunday
    when "monday", "mon", "tmon"
      DateHelper::Weeks.monday
    when "tuesday", "tue", "ttue"
      DateHelper::Weeks.tuesday
    when "wednesday", "wed", "twed"
      DateHelper::Weeks.wednesday
    when "thursday", "thu", "tthu"
      DateHelper::Weeks.thursday
    else 
      DateHelper.parse_arg(stripped)
    end
  end

  # @param date [String]
  def self.define_month(date)
    raise ArgumentError, "Date cannot be nil" unless date
    stripped = date.strip.downcase
    case stripped
    when "january", "jan", "1"
      DateHelper::Months.january
    when "february", "feb", "2"
      DateHelper::Months.february
    when "march", "mar", "3"
      DateHelper::Months.march
    when "april", "apr", "4"
      DateHelper::Months.april
    when "may", "5"
      DateHelper::Months.may
    when "june", "jun", "6"
      DateHelper::Months.june
    when "july", "jul", "7"
      DateHelper::Months.july
    when "august", "aug", "8"
      DateHelper::Months.august
    when "september", "sep", "9"
      DateHelper::Months.september
    when "october", "oct", "10"
      DateHelper::Months.october
    when "november", "nov", "11"
      DateHelper::Months.november
    when "december", "dec", "12"
      DateHelper::Months.december
    else 
      DateHelper.parse_arg(stripped)
    end
  end


end