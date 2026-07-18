class BudgetService
  # @param categories [CategoryRepository]
  # @param transactions [TransactionRepository]
  # @return BudgetService
  def initialize(categories, transactions)
    raise ArgumentError, "Nil value is invalid" unless categories && transactions
    @categories = categories
    @transactions = transactions
  end

  # @param title [String] - keyword argument
  # @param colour [String] - keyword argument
  # @return [Category]
  def create_category(title:, colour:)
    category = Category.new(
      title: title,
      colour: colour
    )

    @categories.save(category)
  end

  # @param title [String] title of Category being edited
  # @param new_title [String] new title - default nil
  # @param new_colour [String] new colour - default nil
  # @return [Category]
  def edit_category(title, new_title:, new_colour:) 
    category = @categories.find_by_title(title)
    return nil unless category

    category.title = new_title if new_title
    category.colour = new_colour if new_colour
    @categories.save(category)
  end

  # @param id [Integer]
  # @return [Boolean]
  def delete_category(category_id)
    @categories.delete(category_id)
  end

  # @return [Array<Category>]
  def get_all_categories
    @categories.all
  end

  # @return [Category]
  def find_category_by_title(category_title)
    @categories.find_by_title(category_title)
  end

  def add_expense(price:, category:,  **options)
    return nil unless category
    transaction = Transaction.new(
      price: price,
      category: category,
      nature: :expense,
      **options
    )

    @transactions.save(transaction)
  end

  def add_income(price:, category:, **options)
    return nil unless category
    transaction = Transaction.new(
      price: price,
      category: category,
      nature: :income,
      **options
    )

    @transactions.save(transaction)
  end

  def add_transaction(price:, category:, merchant:, nature:)
    return nil unless category
    transaction = Transaction.new(
      price: price,
      category: category,
      nature: nature,
      merchant: merchant
    )

    @transactions.save(transaction)
  end

  # @param id [Integer] - ID of transaction being edited
  # @param new_price [Float]
  # @param new_category_title [String]
  # @param new_date [Date]
  # @param new_merchant [String]
  # @param new_nature [Symbol]
  # @return [Transaction]
  def edit_transaction(id, new_price: nil, new_category_title: nil, new_date: nil, new_merchant: nil, new_nature: nil)
    transaction = @transactions.find(id)
    new_category = @categories.find_by_title(title)
    transaction.price = new_price if new_price
    transaction.category = new_category if new_category
    transaction.date = new_date if new_date
    transaction.merchant = new_merchant if new_merchant

    @transactions.save(transaction)
  end

  # @param id [Integer]
  # @return [Boolean]
  def delete_transaction(transaction_id)
    @transactions.delete(transaction_id)
  end

  # @return [Array<String>]
  def merchants
    @categories.merchants
  end

end