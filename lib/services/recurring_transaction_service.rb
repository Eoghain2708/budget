class RecurringTransactionService

  # @param categories [CategoryRepository]
  # @param transactions [TransactionRepository]
  # @param recurrings [RecurringTransactionRepository]
  def initialize(categories, transactions, recurrings)
    @categories = categories
    @transactions = transactions
    @recurrings = recurrings
  end
end