require "date"
require_relative "../helpers/date_helper"

class ReportService
  MONTHS = {
    january: 1, jan: 1,
    february: 2, feb: 2,
    march: 3, mar: 3,
    april: 4, apr: 4,
    may: 5,
    june: 6, jun: 6,
    july: 7, jul: 7,
    august: 8, aug: 8,
    september: 9, sep: 9,
    october: 10, oct: 10,
    november: 11, nov: 11,
    december: 12, dec: 12
  }.freeze


  # @param categories [CategoryRepository]
  # @param transactions [TransactionRepository]
  # @return BudgetService
  def initialize(categories, transactions)
    raise ArgumentError, "Nil value is invalid" unless categories && transactions
    @categories = categories
    @transactions = transactions
  end

  # @param month [String]
  # @param year [Integer]
  # @return [Array<Transaction>]
  def monthly_summary(month, year)
    month = month.to_sym
    raise ArgumentError, "Invalid date" unless MONTHS.key?(month) && year <= Date.today.year
    from = Date.new(year, MONTHS[month], 1)
    
    if Date.today.month == MONTHS[month]
      to = Date.today
      transactions =  @transactions.find_between(from: from, to: to)
    else 
      to = Date.new(year, MONTHS[month], -1)
      transactions =  @transactions.find_between(from: from, to: to)
    end

    build_summary(transactions, from: from, to: to)
  end

  # Returns all transactions within a weekly period of Monday => Sunday
  # Takes in any date and converts it to the previous Monday
  # @param date [Date]
  def weekly_summary(date)
    monday = DateHelper.make_monday(date)
    transactions = @transactions.find_between(from: monday, to: monday + 6)
    
    build_summary(transactions, from: monday, to: monday + 6)
  end

  # @param date [Date]
  # @return [Array<Transaction>]
  def daily_summary(date)
    transactions = @transactions.find_by_date(date)
    
    return {} unless transactions
    
    build_summary(transactions, from: date, to: date)
  end


  private
  # @param transactions [Array<Transaction>]
  # @param from: [Date]
  # @param to: [Date]
  def build_summary(transactions, from:, to:)
    {
      from: from,
      to: to,
      transactions: transactions,
      transaction_count: transactions.size,
      total_spent: transactions.sum(&:price),
      category_breakdown: category_breakdown(transactions),
      merchant_breakdown: merchant_breakdown(transactions),
    }
  end

  # @param transactions [Array<Transaction>]
  # @return [Hash] - { count: Integer, total: Float }
  def category_breakdown(transactions)
    transactions
    .group_by(&:category)
    .transform_values do |ts|
      {
        count: ts.size,
        total: ts.sum(&:price)
      }
    end
  end

  # @param transactions [Array<Transaction>]
  # @return [Hash] - { count: Integer, total: Float }
  def merchant_breakdown(transactions)
    transactions
    .group_by(&:category)
    .transform_values do |ts|
      {
        count: ts.size,
        total: ts.sum(&:price)
      }
    end
  end
end