require "date"

module DateHelper
  
  # @param date [Date]
  # @return [Date]
  def self.make_monday(date)
    days_since_monday = (date.wday - 1) % 7
    date - days_since_monday
  end

  class Weeks
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
  end

  def self.parse_arg(date_string)
    Date.parse(date_string)
  end

  class Months
    class << self
      def current
        today = Date.today
        Date.new(today.year, today.month)
      end

      def previous
        current << 1
      end

      def month(number)
        Date.new(Date.today.year, number)
      end

      def lyear_month(number)
        Date.new(Date.today.year - 1, number)
      end

      def january   = month(1)
      def february  = month(2)
      def march     = month(3)
      def april     = month(4)
      def may       = month(5)
      def june      = month(6)
      def july      = month(7)
      def august    = month(8)
      def september = month(9)
      def october   = month(10)
      def november  = month(11)
      def december  = month(12)

      def last_january   = lyear_month(1)
      def last_february  = lyear_month(2)
      def last_march     = lyear_month(3)
      def last_april     = lyear_month(4)
      def last_may       = lyear_month(5)
      def last_june      = lyear_month(6)
      def last_july      = lyear_month(7)
      def last_august    = lyear_month(8)
      def last_september = lyear_month(9)
      def last_october   = lyear_month(10)
      def last_november  = lyear_month(11)
      def last_december  = lyear_month(12)
    end
  end
end