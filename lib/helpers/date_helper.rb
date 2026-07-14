require "date"

module DateHelper
  
  # @param date [Date]
  # @return [Date]
  def self.make_monday(date)
    days_since_monday = (date.wday - 1) % 7
    date - days_since_monday
  end

  def self.this_week
    date = Date.today
    date - (date.cwday - 1)
  end

  
  def self.next_week
    this_week + 7
  end
  
  def self.last_week
    this_week - 7
  end

  def self.today
    Date.today
  end

  def self.tomorrow
    Date.today + 1
  end

  def self.yesterday
    Date.today - 1
  end

  def self.monday
    this_week
  end

  def self.tuesday
    this_week + 1
  end

  def self.wednesday
    this_week + 2
  end

  def self.thursday
    this_week + 3
  end

  def self.friday
    this_week + 4
  end

  def self.saturday
    this_week + 5
  end

  def self.sunday
    this_week + 6
  end

  def self.nmonday
    next_week
  end

  def self.ntuesday
    next_week + 1
  end

  def self.nwednesday
    next_week + 2
  end

  def self.nthursday
    next_week + 3
  end

  def self.nfriday
    next_week + 4
  end

  def self.nsaturday
    next_week + 5
  end

  def self.nsunday
    next_week + 6
  end

  def self.lmonday
    last_week
  end

  def self.ltuesday
    last_week + 1
  end

  def self.lwednesday
    last_week + 2
  end

  def self.lthursday
    last_week + 3
  end

  def self.lfriday
    last_week + 4
  end

  def self.lsaturday
    last_week + 5
  end

  def self.lsunday
    last_week + 6
  end

  def self.parse_arg(date_string)
    Date.parse(date_string)
  end

  def self.month
    month = Date.today.month
    Date.new(Date.year, month, 1)
  end

  def self.lmonth
    month = Date.today.month
    Date.new(Date.year, month - 1, 1)
  end
end