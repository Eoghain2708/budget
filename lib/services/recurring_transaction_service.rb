require_relative "../../lib/models/recurring_transaction"

class RecurringTransactionService

  # @param categories [CategoryRepository]
  # @param transactions [TransactionRepository]
  # @param recurrings [RecurringTransactionRepository]
  def initialize(categories, transactions, recurrings)
    @categories = categories
    @transactions = transactions
    @recurrings = recurrings
  end

  # @param category [Category]
  # @param merchant [String]
  # @param price [Float]
  # @param init_date [Date]
  # @param nature [Symbol]
  # @param period_type [Symbol]
  # @return [RecurringTransaction]
  def create_recurring(category:, merchant:, price:, init_date:, nature:, period_type:)
    recurring = RecurringTransaction.new(
      category:,
      merchant:,
      price:,
      init_date:,
      nature:,
      period_type:
    )

    @recurrings.save(recurring)
  end

  # @param recurring [RecurringTransaction] - the RecurringTransaction to be edited
  # @param category [Category]
  # @param merchant [String]
  # @param price [Float]
  # @param init_date [Date]
  # @param nature [Symbol]
  # @param period_type [Symbol]
  # @return [RecurringTransaction]
  def edit_recurring(recurring, category:, merchant:, price:, init_date:, nature:, period_type:)
    recurring.category = category if category
    recurring.merchant = merchant if merchant
    recurring.price = price if price
    recurring.init_date = init_date if init_date
    recurring.nature = nature if nature
    recurring.period_type = period_type if period_type

    @recurrings.save(recurring)
  end

  # @param recurring [RecurringTransaction]
  # @return [Boolean]
  def delete_recurring(recurring)
    @recurrings.delete(recurring.id)
  end

  # @param category [Category]
  # @param merchant [String]
  # @param price [Float]
  # @param init_date [Date]
  # @param nature [Symbol]
  # @param period_type [Symbol]
  # @return [Array<RecurringTransaction>]
  def find_by_attrs(category:, merchant:, price:, init_date:, nature:, period_type:)
    @recurrings.find_by_attrs(category:, merchant:, price:, init_date:, nature:, period_type:)
  end

  # @return [Array<RecurringTransaction>]
  def all
    @recurrings.all
  end

end