require_relative '../test_helper'

class PeriodDefinerTest < Minitest::Test
  #
  # Weeks
  #

  def test_define_this_week
    assert_equal DateHelper::Weeks.this_week,
                 PeriodDefiner.define_week('thisweek')
  end

  def test_define_last_week_alias
    assert_equal DateHelper::Weeks.last_week,
                 PeriodDefiner.define_week('lw')
  end

  def test_define_week_parses_date
    expected = Date.new(2026, 7, 22)

    assert_equal expected,
                 PeriodDefiner.define_week('2026-07-22')
  end

  #
  # Days
  #

  def test_define_today
    assert_equal Date.today,
                 PeriodDefiner.define_day('today')
  end

  def test_define_today_alias
    assert_equal Date.today,
                 PeriodDefiner.define_day('td')
  end

  def test_define_yesterday
    assert_equal Date.today - 1,
                 PeriodDefiner.define_day('yesterday')
  end

  def test_define_friday
    assert_equal DateHelper::Weeks.friday,
                 PeriodDefiner.define_day('fri')
  end

  def test_define_day_parses_date
    expected = Date.new(2026, 7, 22)

    assert_equal expected,
                 PeriodDefiner.define_day('2026-07-22')
  end

  #
  # Months
  #

  def test_define_january
    assert_equal DateHelper::Months.january,
                 PeriodDefiner.define_month('january')
  end

  def test_define_month_number
    assert_equal DateHelper::Months.july,
                 PeriodDefiner.define_month('7')
  end

  def test_define_month_alias
    assert_equal DateHelper::Months.december,
                 PeriodDefiner.define_month('dec')
  end

  def test_define_month_parses_date
    expected = Date.new(2026, 7, 22)

    assert_equal expected,
                 PeriodDefiner.define_month('2026-07-22')
  end

  #
  # Errors
  #

  def test_define_week_raises_for_nil
    assert_raises(ArgumentError) do
      PeriodDefiner.define_week(nil)
    end
  end

  def test_define_day_raises_for_nil
    assert_raises(ArgumentError) do
      PeriodDefiner.define_day(nil)
    end
  end

  def test_define_month_raises_for_nil
    assert_raises(ArgumentError) do
      PeriodDefiner.define_month(nil)
    end
  end
end
