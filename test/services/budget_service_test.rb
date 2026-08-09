require_relative '../test_helper'

class BudgetServiceTest < Minitest::Test
  def setup
    @food = category(id: 1, title: 'Food', colour: 'red')
    @work = category(id: 2, title: 'Work', colour: 'green')

    @categories_repo = FakeCategoryRepository.new(
      all: [@food, @work],
      find_by_title: @work,
      search_by_title: @food
    )

    @transaction = transaction(
      id: 10,
      price: 12.5,
      date: Date.today,
      category: @food,
      merchant: 'Lidl',
      nature: :expense
    )

    @transactions_repo = FakeTransactionRepository.new(
      find: @transaction,
      between: [@transaction],
      by_date: [@transaction],
      merchants: %w[Lidl Tesco],
      recent_merchants: %w[Lidl Tesco]
    )

    @service = BudgetService.new(@categories_repo, @transactions_repo)
  end

  def test_initialize_requires_both_repositories
    assert_raises(ArgumentError) { BudgetService.new(nil, @transactions_repo) }
    assert_raises(ArgumentError) { BudgetService.new(@categories_repo, nil) }
  end

  def test_create_category_saves_new_category
    created = @service.create_category(title: 'Bills', colour: 'blue')

    assert_equal 'Bills', created.title
    assert_equal 'blue', created.colour
    assert_equal created, @categories_repo.saved
  end

  def test_edit_category_returns_nil_when_category_missing
    assert_nil @service.edit_category(nil, new_title: 'New')
  end

  def test_edit_category_updates_and_saves
    edited = @service.edit_category(@food, new_title: 'Groceries', new_colour: 'bright_green')

    assert_equal 'Groceries', edited.title
    assert_equal 'bright_green', edited.colour
    assert_equal edited, @categories_repo.saved
  end

  def test_delete_category_delegates_to_repository
    assert_equal true, @service.delete_category(7)
    assert_equal 7, @categories_repo.deleted_id
  end

  def test_get_all_categories_returns_all_categories
    assert_equal [@food, @work], @service.get_all_categories
  end

  def test_find_category_by_title_delegates_to_repository
    assert_equal @work, @service.find_category_by_title('Work')
    assert_equal 'Work', @categories_repo.find_by_title_arg
  end

  def test_search_by_title_delegates_to_repository
    assert_equal @food, @service.search_by_title('Fo')
    assert_equal 'Fo', @categories_repo.search_by_title_arg
  end

  def test_find_transaction_delegates_to_repository
    assert_equal @transaction, @service.find_transaction(10)
    assert_equal 10, @transactions_repo.find_id
  end

  def test_add_transaction_returns_nil_when_category_missing
    assert_nil @service.add_transaction(
      price: 5.60,
      category: nil,
      merchant: 'Lidl',
      nature: :expense
    )
  end

  def test_add_transaction_saves_transaction
    result = @service.add_transaction(
      price: 5.60,
      category: @food,
      merchant: 'Lidl',
      nature: :expense
    )

    assert_equal 5.60, result.price
    assert_equal @food, result.category
    assert_equal 'Lidl', result.merchant
    assert_equal :expense, result.nature
    assert_equal result, @transactions_repo.saved
  end

  def test_edit_transaction_updates_and_saves
    new_date = Date.today - 1
    new_category = @work

    edited = @service.edit_transaction(
      10,
      new_price: 20.0,
      new_category: new_category,
      new_date: new_date,
      new_merchant: 'Tesco',
      new_nature: :income
    )

    assert_equal 20.0, edited.price
    assert_equal new_category, edited.category
    assert_equal new_date, edited.date
    assert_equal 'Tesco', edited.merchant
    assert_equal :income, edited.nature
    assert_equal edited, @transactions_repo.saved
  end

  def test_delete_transaction_delegates_to_repository
    assert_equal true, @service.delete_transaction(10)
    assert_equal 10, @transactions_repo.deleted_id
  end

  def test_find_transactions_between_delegates_to_repository
    from = Date.today - 7
    to = Date.today

    assert_equal [@transaction], @service.find_transactions_between(from: from, to: to)
    assert_equal [from, to], @transactions_repo.find_between_args
  end

  def test_merchants_delegates_to_repository
    assert_equal %w[Lidl Tesco], @service.merchants
  end

  def test_recent_merchants_delegates_to_repository
    assert_equal %w[Lidl Tesco], @service.recent_merchants(@food)
    assert_equal @food, @transactions_repo.recent_merchants_arg
  end
end
