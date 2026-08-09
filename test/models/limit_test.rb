require_relative '../test_helper'

class LimitTest < Minitest::Test
  def setup
    @category = Category.new(
      id: 1,
      title: 'Personal',
      colour: 'bright_cyan'
    )

    @merchant = 'Lidl'
  end

  # --------------------
  # Initialization
  # --------------------

  def test_creates_category_limit
    limit = Limit.new(
      category: @category,
      amount: 100.0,
      period_type: :weekly
    )

    assert_equal @category, limit.category
    assert_nil limit.merchant
    assert_equal 100.0, limit.amount
    assert_equal :weekly, limit.period_type
  end

  def test_creates_merchant_limit
    limit = Limit.new(
      merchant: @merchant,
      amount: 50.0,
      period_type: :monthly
    )

    assert_nil limit.category
    assert_equal @merchant, limit.merchant
    assert_equal 50.0, limit.amount
    assert_equal :monthly, limit.period_type
  end

  def test_id_defaults_to_nil
    limit = Limit.new(
      category: @category,
      amount: 100.0,
      period_type: :weekly
    )

    assert_nil limit.id
  end

  def test_accepts_id
    limit = Limit.new(
      id: 42,
      category: @category,
      amount: 100.0,
      period_type: :weekly
    )

    assert_equal 42, limit.id
  end

  # --------------------
  # Validation
  # --------------------

  def test_requires_amount
    error = assert_raises(ArgumentError) do
      Limit.new(
        category: @category,
        period_type: :weekly
      )
    end

    assert_equal 'Limit amount must be specified', error.message
  end

  def test_requires_period_type
    error = assert_raises(ArgumentError) do
      Limit.new(
        category: @category,
        amount: 100.0
      )
    end

    assert_equal 'Period (e.g week, month) must be specified', error.message
  end

  def test_rejects_invalid_period_type
    error = assert_raises(ArgumentError) do
      Limit.new(
        category: @category,
        amount: 100.0,
        period_type: :fortnightly
      )
    end

    assert_match(/Invalid period type/, error.message)
  end

  def test_requires_category_or_merchant
    error = assert_raises(ArgumentError) do
      Limit.new(
        amount: 100.0,
        period_type: :weekly
      )
    end

    assert_equal 'Either category or merchant must be specified', error.message
  end

  def test_rejects_category_and_merchant_together
    error = assert_raises(ArgumentError) do
      Limit.new(
        category: @category,
        merchant: @merchant,
        amount: 100.0,
        period_type: :weekly
      )
    end

    assert_equal(
      'Limit cannot apply to both a merchant and a category',
      error.message
    )
  end

  # --------------------
  # Period predicates
  # --------------------

  def test_daily_returns_true_for_daily_limit
    limit = build_limit(period_type: :daily)

    assert limit.daily?
  end

  def test_daily_returns_false_for_non_daily_limit
    limit = build_limit(period_type: :weekly)

    refute limit.daily?
  end

  def test_weekly_returns_true_for_weekly_limit
    limit = build_limit(period_type: :weekly)

    assert limit.weekly?
  end

  def test_weekly_returns_false_for_non_weekly_limit
    limit = build_limit(period_type: :daily)

    refute limit.weekly?
  end

  def test_monthly_returns_true_for_monthly_limit
    limit = build_limit(period_type: :monthly)

    assert limit.monthly?
  end

  def test_monthly_returns_false_for_non_monthly_limit
    limit = build_limit(period_type: :weekly)

    refute limit.monthly?
  end

  def test_yearly_returns_true_for_yearly_limit
    limit = build_limit(period_type: :yearly)

    assert limit.yearly?
  end

  def test_yearly_returns_false_for_non_yearly_limit
    limit = build_limit(period_type: :monthly)

    refute limit.yearly?
  end

  # --------------------
  # Category / merchant
  # --------------------

  def test_category_returns_true_for_category_limit
    limit = build_limit(category: @category)

    assert limit.category?
  end

  def test_category_returns_false_for_merchant_limit
    limit = build_limit_with_merchant

    refute limit.category?
  end

  def test_merchant_returns_true_for_merchant_limit
    limit = build_limit_with_merchant

    assert limit.merchant?
  end

  def test_merchant_returns_false_for_category_limit
    limit = build_limit_with_category

    refute limit.merchant?
  end

  def test_type_returns_category_for_category_limit
    limit = build_limit_with_category

    assert_equal :category, limit.type
  end

  def test_type_returns_merchant_for_merchant_limit
    limit = build_limit_with_merchant

    assert_equal :merchant, limit.type
  end

  # --------------------
  # Period string
  # --------------------

  def test_daily_period_string
    limit = build_limit(period_type: :daily)

    assert_equal 'day', limit.get_period_string
  end

  def test_weekly_period_string
    limit = build_limit(period_type: :weekly)

    assert_equal 'week', limit.get_period_string
  end

  def test_monthly_period_string
    limit = build_limit(period_type: :monthly)

    assert_equal 'month', limit.get_period_string
  end

  def test_yearly_period_string
    limit = build_limit(period_type: :yearly)

    assert_equal 'year', limit.get_period_string
  end

  # --------------------
  # Equality
  # --------------------

  def test_limits_with_same_id_are_equal
    limit1 = build_limit(id: 1)
    limit2 = build_limit(id: 1)

    assert_equal limit1, limit2
  end

  def test_limits_with_different_ids_are_not_equal
    limit1 = build_limit(id: 1)
    limit2 = build_limit(id: 2)

    refute_equal limit1, limit2
  end

  def test_limit_is_not_equal_to_different_object
    limit = build_limit(id: 1)

    refute_equal limit, 'not a limit'
  end

  def test_equal_limits_have_same_hash
    limit1 = build_limit(id: 1)
    limit2 = build_limit(id: 1)

    assert_equal limit1.hash, limit2.hash
  end

  # --------------------
  # Helpers
  # --------------------

  def build_limit(
    id: nil,
    category: @category,
    merchant: nil,
    amount: 100.0,
    period_type: :weekly
  )
    Limit.new(
      id: id,
      category: category,
      merchant: merchant,
      amount: amount,
      period_type: period_type
    )
  end

  def build_limit_with_category(
    id: nil,
    category: @category,
    merchant: nil,
    amount: 100.0,
    period_type: :weekly
  )
    Limit.new(
      id: id,
      category: category,
      merchant: merchant,
      amount: amount,
      period_type: period_type
    )
  end

  def build_limit_with_merchant(
    id: nil,
    category: nil,
    merchant: @merchant,
    amount: 100.0,
    period_type: :weekly
  )
    Limit.new(
      id: id,
      category: category,
      merchant: merchant,
      amount: amount,
      period_type: period_type
    )
  end
end
