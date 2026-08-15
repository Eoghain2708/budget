require_relative "../test_helper"

class RecurringTransactionTest < Minitest::Test
  def setup
    @category = Category.new(
      id: 1,
      title: "Bills",
      colour: "red"
    )

    @valid_attributes = {
      category: @category,
      merchant: "Netflix",
      init_date: Date.new(2026, 8, 15),
      period_type: :monthly,
      price: 15.99,
      nature: :expense
    }
  end

  # -------------------------
  # INITIALIZATION
  # -------------------------

  def test_creates_valid_recurring_transaction
    recurring = RecurringTransaction.new(**@valid_attributes)

    assert_instance_of RecurringTransaction, recurring
    assert_equal @category, recurring.category
    assert_equal "Netflix", recurring.merchant
    assert_equal Date.new(2026, 8, 15), recurring.init_date
    assert_equal Date.new(2026, 8, 15), recurring.next_due
    assert_equal :monthly, recurring.period_type
    assert_equal 15.99, recurring.price
    assert_equal :expense, recurring.nature
  end

  def test_id_defaults_to_nil
    recurring = RecurringTransaction.new(**@valid_attributes)

    assert_nil recurring.id
  end

  def test_allows_id_to_be_specified
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      id: 42
    )

    assert_equal 42, recurring.id
  end

  # -------------------------
  # VALIDATION
  # -------------------------

  def test_requires_price
    error = assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        price: nil
      )
    end

    assert_equal "Price needs to be specified", error.message
  end


  def test_rejects_negative_price
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        price: -10
      )
    end
  end

  def test_requires_merchant
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        merchant: nil
      )
    end
  end

  def test_requires_category
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        category: nil
      )
    end
  end

  def test_requires_init_date
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        init_date: nil
      )
    end
  end

  def test_requires_period_type
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        period_type: nil
      )
    end
  end

  def test_rejects_invalid_period_type
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        period_type: :fortnightly
      )
    end
  end

  def test_requires_nature
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        nature: nil
      )
    end
  end

  def test_rejects_invalid_nature
    assert_raises(ArgumentError) do
      RecurringTransaction.new(
        **@valid_attributes,
        nature: :invalid
      )
    end
  end

  # -------------------------
  # PERIOD PREDICATES
  # -------------------------

  def test_daily?
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      period_type: :daily
    )

    assert recurring.daily?
    refute recurring.weekly?
    refute recurring.monthly?
    refute recurring.yearly?
  end

  def test_weekly?
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      period_type: :weekly
    )

    assert recurring.weekly?
    refute recurring.daily?
    refute recurring.monthly?
    refute recurring.yearly?
  end

  def test_monthly?
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      period_type: :monthly
    )

    assert recurring.monthly?
    refute recurring.daily?
    refute recurring.weekly?
    refute recurring.yearly?
  end

  def test_yearly?
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      period_type: :yearly
    )

    assert recurring.yearly?
    refute recurring.daily?
    refute recurring.weekly?
    refute recurring.monthly?
  end

  # -------------------------
  # NATURE PREDICATES
  # -------------------------

  def test_expense?
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      nature: :expense
    )

    assert recurring.expense?
    refute recurring.income?
    refute recurring.investment?
  end

  def test_income?
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      nature: :income
    )

    assert recurring.income?
    refute recurring.expense?
    refute recurring.investment?
  end

  def test_investment?
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      nature: :investment
    )

    assert recurring.investment?
    refute recurring.expense?
    refute recurring.income?
  end

  # -------------------------
  # INITIAL NEXT DUE
  # -------------------------

  def test_next_due_is_initial_date
    date = Date.new(2026, 8, 15)

    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: date
    )

    assert_equal date, recurring.next_due
  end

  # -------------------------
  # DAILY
  # -------------------------

  def test_daily_recurring_transaction_moves_forward_one_day
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2026, 8, 15),
      period_type: :daily
    )

    recurring.update_next_due

    assert_equal Date.new(2026, 8, 16), recurring.next_due
  end

  # -------------------------
  # WEEKLY
  # -------------------------

  def test_weekly_recurring_transaction_moves_forward_seven_days
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2026, 8, 15),
      period_type: :weekly
    )

    recurring.update_next_due

    assert_equal Date.new(2026, 8, 22), recurring.next_due
  end

  # -------------------------
  # MONTHLY
  # -------------------------

  def test_monthly_recurring_transaction_moves_forward_one_month
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2026, 8, 15),
      period_type: :monthly
    )

    recurring.update_next_due

    assert_equal Date.new(2026, 9, 15), recurring.next_due
  end

  def test_monthly_recurring_transaction_handles_31st
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2026, 1, 31),
      period_type: :monthly
    )

    recurring.update_next_due
    assert_equal Date.new(2026, 2, 28), recurring.next_due

    recurring.update_next_due
    assert_equal Date.new(2026, 3, 31), recurring.next_due

    recurring.update_next_due
    assert_equal Date.new(2026, 4, 30), recurring.next_due

    recurring.update_next_due
    assert_equal Date.new(2026, 5, 31), recurring.next_due
  end

  def test_monthly_recurring_transaction_handles_31st_in_leap_year
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2028, 1, 31),
      period_type: :monthly
    )

    recurring.update_next_due

    assert_equal Date.new(2028, 2, 29), recurring.next_due

    recurring.update_next_due

    assert_equal Date.new(2028, 3, 31), recurring.next_due
  end

  # -------------------------
  # YEARLY
  # -------------------------

  def test_yearly_recurring_transaction_moves_forward_one_year
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2026, 8, 15),
      period_type: :yearly
    )

    recurring.update_next_due

    assert_equal Date.new(2027, 8, 15), recurring.next_due
  end

  def test_yearly_recurring_transaction_handles_february_29
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2028, 2, 29),
      period_type: :yearly
    )

    recurring.update_next_due

    assert_equal Date.new(2029, 2, 28), recurring.next_due

    recurring.update_next_due

    assert_equal Date.new(2030, 2, 28), recurring.next_due
  end

  def test_yearly_recurring_transaction_returns_to_february_29_in_leap_year
    recurring = RecurringTransaction.new(
      **@valid_attributes,
      init_date: Date.new(2028, 2, 29),
      period_type: :yearly
    )

    recurring.update_next_due

    assert_equal Date.new(2029, 2, 28), recurring.next_due

    recurring.update_next_due
    recurring.update_next_due

    assert_equal Date.new(2031, 2, 28), recurring.next_due

    recurring.update_next_due

    assert_equal Date.new(2032, 2, 29), recurring.next_due
  end

  # -------------------------
  # ACCESSORS
  # -------------------------

  def test_attributes_can_be_updated
    recurring = RecurringTransaction.new(**@valid_attributes)

    new_category = Category.new(
      id: 2,
      title: "Entertainment",
      colour: "cyan"
    )

    recurring.category = new_category
    recurring.merchant = "Amazon"
    recurring.price = 25.50
    recurring.period_type = :weekly
    recurring.nature = :income

    assert_equal new_category, recurring.category
    assert_equal "Amazon", recurring.merchant
    assert_equal 25.50, recurring.price
    assert_equal :weekly, recurring.period_type
    assert_equal :income, recurring.nature
  end

  # -------------------------
  # EQUALITY
  # -------------------------

  def test_recurring_transactions_with_same_id_are_equal
    first = RecurringTransaction.new(
      **@valid_attributes,
      id: 1
    )

    second = RecurringTransaction.new(
      **@valid_attributes,
      id: 1
    )

    assert_equal first, second
  end

  def test_recurring_transactions_with_different_ids_are_not_equal
    first = RecurringTransaction.new(
      **@valid_attributes,
      id: 1
    )

    second = RecurringTransaction.new(
      **@valid_attributes,
      id: 2
    )

    refute_equal first, second
  end

  def test_recurring_transaction_is_not_equal_to_other_object
    recurring = RecurringTransaction.new(**@valid_attributes)

    refute_equal recurring, "not a recurring transaction"
  end

  def test_equal_recurring_transactions_have_same_hash
    first = RecurringTransaction.new(
      **@valid_attributes,
      id: 1
    )

    second = RecurringTransaction.new(
      **@valid_attributes,
      id: 1
    )

    assert_equal first.hash, second.hash
  end
end