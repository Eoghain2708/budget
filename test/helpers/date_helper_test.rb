require_relative "../test_helper"

class DateHelperTest < Minitest::Test
  def test_make_monday_from_monday
    monday = Date.new(2026, 7, 13)

    assert_equal monday, DateHelper.make_monday(monday)
  end

  def test_make_monday_from_tuesday
    tuesday = Date.new(2026, 7, 14)

    assert_equal Date.new(2026, 7, 13),
                 DateHelper.make_monday(tuesday)
  end

  def test_make_monday_from_sunday
    sunday = Date.new(2026, 7, 19)

    assert_equal Date.new(2026, 7, 13),
                 DateHelper.make_monday(sunday)
  end

  def test_parse_arg
    assert_equal Date.new(2026, 7, 22),
                 DateHelper.parse_arg("2026-07-22")
  end
end

class WeeksTest < Minitest::Test
  def setup
    @today = Date.today
    @this_week = DateHelper::Weeks.this_week
  end

  def test_today
    assert_equal @today, DateHelper::Weeks.today
  end

  def test_tomorrow
    assert_equal @today + 1,
                 DateHelper::Weeks.tomorrow
  end

  def test_yesterday
    assert_equal @today - 1,
                 DateHelper::Weeks.yesterday
  end

  def test_this_week_is_monday
    assert_equal 1,
                 DateHelper::Weeks.this_week.cwday
  end

  def test_next_week
    assert_equal @this_week + 7,
                 DateHelper::Weeks.next_week
  end

  def test_last_week
    assert_equal @this_week - 7,
                 DateHelper::Weeks.last_week
  end

  def test_days_of_week
    assert_equal @this_week,     DateHelper::Weeks.monday
    assert_equal @this_week + 1, DateHelper::Weeks.tuesday
    assert_equal @this_week + 2, DateHelper::Weeks.wednesday
    assert_equal @this_week + 3, DateHelper::Weeks.thursday
    assert_equal @this_week + 4, DateHelper::Weeks.friday
    assert_equal @this_week + 5, DateHelper::Weeks.saturday
    assert_equal @this_week + 6, DateHelper::Weeks.sunday
  end

  def test_next_week_days
    next_week = DateHelper::Weeks.next_week

    assert_equal next_week,     DateHelper::Weeks.nmonday
    assert_equal next_week + 6, DateHelper::Weeks.nsunday
  end

  def test_last_week_days
    last_week = DateHelper::Weeks.last_week

    assert_equal last_week,     DateHelper::Weeks.lmonday
    assert_equal last_week + 6, DateHelper::Weeks.lsunday
  end
end

class MonthsTest < Minitest::Test
  def test_current_month
    today = Date.today

    assert_equal Date.new(today.year, today.month),
                 DateHelper::Months.current
  end

  def test_previous_month
    assert_equal DateHelper::Months.current << 1,
                 DateHelper::Months.previous
  end

  def test_named_months
    year = Date.today.year

    assert_equal Date.new(year, 1),  DateHelper::Months.january
    assert_equal Date.new(year, 7),  DateHelper::Months.july
    assert_equal Date.new(year, 12), DateHelper::Months.december
  end

  def test_last_year_months
    year = Date.today.year - 1

    assert_equal Date.new(year, 1),  DateHelper::Months.last_january
    assert_equal Date.new(year, 7),  DateHelper::Months.last_july
    assert_equal Date.new(year, 12), DateHelper::Months.last_december
  end
end