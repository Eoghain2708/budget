require_relative '../test_helper'

class TransactionTest < Minitest::Test
  def setup
    @category = Category.new(
      id: 1,
      title: 'Food',
      colour: 'red'
    )
  end

  def test_creates_transaction
    transaction = Transaction.new(
      id: 1,
      price: 25.50,
      date: Date.today,
      category: @category,
      merchant: 'Lidl',
      nature: :expense
    )

    assert_equal 1, transaction.id
    assert_equal 25.50, transaction.price
    assert_equal Date.today, transaction.date
    assert_equal @category, transaction.category
    assert_equal 'Lidl', transaction.merchant
    assert_equal :expense, transaction.nature
  end

  def test_defaults
    transaction = Transaction.new(
      price: 10,
      category: @category
    )

    assert_equal Date.today, transaction.date
    assert_equal 'unspecified', transaction.merchant
    assert_equal :expense, transaction.nature
  end

  def test_price_must_be_positive
    assert_raises(ArgumentError) do
      Transaction.new(
        price: 0,
        category: @category
      )
    end

    assert_raises(ArgumentError) do
      Transaction.new(
        price: -5,
        category: @category
      )
    end
  end

  def test_future_date_not_allowed
    assert_raises(ArgumentError) do
      Transaction.new(
        price: 10,
        category: @category,
        date: Date.today + 1
      )
    end
  end

  def test_invalid_nature
    assert_raises(ArgumentError) do
      Transaction.new(
        price: 10,
        category: @category,
        nature: :banana
      )
    end
  end

  def test_income
    transaction = Transaction.new(
      price: 50,
      category: @category,
      nature: :income
    )

    assert transaction.income?
    refute transaction.expense?
  end

  def test_expense
    transaction = Transaction.new(
      price: 50,
      category: @category,
      nature: :expense
    )

    assert transaction.expense?
    refute transaction.income?
  end

  def test_transactions_with_same_id_are_equal
    first = Transaction.new(
      id: 1,
      price: 10,
      category: @category
    )

    second = Transaction.new(
      id: 1,
      price: 100,
      category: @category,
      merchant: 'Tesco'
    )

    assert_equal first, second
  end

  def test_transactions_with_different_ids_are_not_equal
    first = Transaction.new(
      id: 1,
      price: 10,
      category: @category
    )

    second = Transaction.new(
      id: 2,
      price: 10,
      category: @category
    )

    refute_equal first, second
  end
end
