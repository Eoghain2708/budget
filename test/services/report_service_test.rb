require_relative '../test_helper'

class ReportServiceTest < Minitest::Test
  def setup
    @food = category(id: 1, title: 'Personal', colour: 'bright_cyan')
    @work = category(id: 2, title: 'Work', colour: 'red')
    @relationship = category(id: 3, title: 'Relationship', colour: 'magenta')
    @investments = category(id: 4, title: 'Investments', colour: 'blue')

    today = Date.today

    @transactions = [
      transaction(id: 1, price: 88.0, date: today, category: @relationship, merchant: 'Test6', nature: :expense),
      transaction(id: 2, price: 40.0, date: today, category: @relationship, merchant: 'Test5', nature: :expense),
      transaction(id: 3, price: 22.0, date: today, category: @food, merchant: 'Test2', nature: :income),
      transaction(id: 4, price: 12.0, date: today, category: @food, merchant: 'Test3', nature: :income),
      transaction(id: 5, price: 120.0, date: today, category: @work, merchant: 'Test1', nature: :income),
      transaction(id: 6, price: 5.0, date: today, category: @relationship, merchant: 'Test4', nature: :expense),
      transaction(id: 7, price: 10.0, date: today, category: @work, merchant: 'Test1', nature: :expense),
      transaction(id: 8, price: 250.0, date: today, category: @investments, merchant: 'Test7', nature: :investment)
    ]

    @transactions_repo = FakeTransactionRepository.new(
      between: @transactions,
      by_date: @transactions
    )

    @service = ReportService.new(FakeCategoryRepository.new, @transactions_repo)
  end

  def test_initialize_requires_both_repositories
    assert_raises(ArgumentError) { ReportService.new(nil, @transactions_repo) }
    assert_raises(ArgumentError) { ReportService.new(FakeCategoryRepository.new, nil) }
  end

  def test_weekly_summary_builds_correct_summary
    date = Date.today
    monday = DateHelper.make_monday(date)
    sunday = monday + 6

    summary = @service.weekly_summary(date)

    assert_equal monday, summary[:from]
    assert_equal sunday, summary[:to]
    assert_equal @transactions, summary[:transactions]
    assert_equal 7, summary[:transaction_count]
    assert_equal 143.0, summary[:total_expense]
    assert_equal 154.0, summary[:total_income]
    assert_equal 250.0, summary[:total_investment]
    assert_equal 11.0, summary[:net_gain]
    assert_equal [monday, sunday], @transactions_repo.find_between_args
  end

  def test_weekly_summary_sorts_category_breakdown_by_net_descending
    summary = @service.weekly_summary(Date.today)

    assert_equal [@work, @food, @relationship], summary[:category_breakdown].keys
  end

  def test_weekly_summary_sorts_merchant_breakdown_by_net_descending
    summary = @service.weekly_summary(Date.today)

    assert_equal %w[
      Test1
      Test2
      Test3
      Test4
      Test5
      Test6
    ], summary[:merchant_breakdown].keys
  end

  def test_weekly_summary_calculates_category_percentages
    summary = @service.weekly_summary(Date.today)

    work = summary[:category_breakdown][@work]
    food = summary[:category_breakdown][@food]
    relationship = summary[:category_breakdown][@relationship]

    assert_in_delta 77.92, work[:income][:percentage], 0.01
    assert_in_delta 6.99, work[:expense][:percentage], 0.01
    assert_in_delta 22.08, food[:income][:percentage], 0.01
    assert_in_delta 93.01, relationship[:expense][:percentage], 0.01
  end

  def test_weekly_summary_calculates_merchant_percentages
    summary = @service.weekly_summary(Date.today)

    test1 = summary[:merchant_breakdown]['Test1']

    assert_in_delta 77.92, test1[:income][:percentage], 0.01
    assert_in_delta 6.99, test1[:expense][:percentage], 0.01
  end

  def test_monthly_summary_builds_correct_range
    from = Date.new(Date.today.year, Date.today.month, 1)
    to = Date.new(from.year, from.month, -1)

    summary = @service.monthly_summary(from)

    assert_equal from, summary[:from]
    assert_equal to, summary[:to]
    assert_equal [from, to], @transactions_repo.find_between_args
  end

  def test_daily_summary_builds_correct_range
    date = Date.today
    summary = @service.daily_summary(date)

    assert_equal date, summary[:from]
    assert_equal date, summary[:to]
    assert_equal @transactions, summary[:transactions]
    assert_equal date, @transactions_repo.find_by_date_arg
  end

  def test_daily_summary_returns_empty_hash_when_no_transactions
    empty_repo = FakeTransactionRepository.new(by_date: nil)
    service = ReportService.new(FakeCategoryRepository.new, empty_repo)

    assert_equal({}, service.daily_summary(Date.today))
  end

  def test_find_all_expenses_filters_expenses
    result = @service.find_all_expenses(@transactions)

    assert_equal [@transactions[0], @transactions[1], @transactions[5], @transactions[6]], result
  end

  def test_find_all_earnings_filters_income
    result = @service.find_all_earnings(@transactions)

    assert_equal [@transactions[2], @transactions[3], @transactions[4]], result
  end
end
