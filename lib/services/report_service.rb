require 'date'
require_relative '../helpers/date_helper'

class ReportService
  # @param categories [CategoryRepository]
  # @param transactions [TransactionRepository]
  # @return [ReportService]
  def initialize(categories, transactions)
    raise ArgumentError, 'Nil value is invalid' unless categories && transactions

    @categories = categories
    @transactions = transactions
  end

  # @param from [Date]
  # @return [Array<Transaction>]
  def monthly_summary(from)
    to = Date.new(from.year, from.month, -1)

    transactions = @transactions.find_between(from: from, to: to)
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

  # @param date [Date]
  # @return [Array<Transaction>]
  def yearly_summary(date)
    from = DateHelper.make_start_of_year(date)
    to = Date.new(from.year, 12, 31)
    transactions = @transactions.find_between(from: from, to: to)
    build_summary(transactions, from: from, to: to)
  end

  # @param transactions [Array<Transaction>]
  # @return [Array<Transactions]
  def find_all_expenses(transactions)
    transactions.select { |t| t.nature == :expense }
  end

  # @param transactions [Array<Transaction>]
  # @return [Array<Transaction>]
  def find_all_earnings(transactions)
    transactions.select { |t| t.nature == :income }
  end

  # @param transactions [Array<Transaction>]
  # @return [Array<Transaction>]
  def find_all_investments(transactions)
    transactions.select { |t| t.nature == :investment }
  end

  private

  # @param transactions [Array<Transaction>]
  # @param from: [Date]
  # @param to: [Date]
  # @return [Hash] => {
  # from: Date,
  # to: Date,
  # transactions: Array<Transaction>,
  # transaction_count: Integer,
  # total_spent: Float,
  # category_breakdown: Hash,
  # merchant_breakdown: Hash
  # }
  def build_summary(transactions, from:, to:)
    tracked_transactions = transactions.select { |t| t.counts_towards_net_gain? } # investments don't impact net gain
    investments = transactions.select { |t| t.investment? }

    result = {
      from: from,
      to: to,
      transactions: transactions,
      transaction_count: tracked_transactions.size,
      total_expense: find_all_expenses(tracked_transactions).sum(&:price),
      total_income: find_all_earnings(tracked_transactions).sum(&:price),
      investment_count: investments.size,
      total_investment: investments.sum(&:price),
      net_gain: find_all_earnings(transactions).sum(&:price) - find_all_expenses(transactions).sum(&:price)
    }

    totals = { income: result[:total_income], expense: result[:total_expense] }
    result[:category_breakdown] = category_breakdown(tracked_transactions, totals)
    result[:merchant_breakdown] = merchant_breakdown(tracked_transactions, totals)
    result[:investment_breakdown] = investment_breakdown(investments)

    # sort category_breakdown
    sorted_category_breakdown = result[:category_breakdown].sort_by do |_, natures|
      income = natures.dig(:income, :total) || 0
      expense = natures.dig(:expense, :total) || 0
      income - expense
    end.reverse
    result[:category_breakdown] = sorted_category_breakdown.to_h

    # sort merchant_breakdown
    sorted_merchant_breakdown = result[:merchant_breakdown].sort_by do |_, natures|
      income = natures.dig(:income, :total) || 0
      expense = natures.dig(:expense, :total) || 0
      income - expense
    end.reverse
    result[:merchant_breakdown] = sorted_merchant_breakdown.to_h

    result
  end

  # @param transactions [Array<Transaction>]
  # @param totals [Hash] { income: Float, expense: Float }
  # @return [Hash] - { count: Integer, total: Float, percentage: Float }
  def category_breakdown(transactions, totals)
    transactions
      .group_by(&:category)
      .transform_values do |ts|
        ts.group_by(&:nature)
          .each_with_object({}) do |(nature, group), result|
            total = group.sum(&:price)

            result[nature] =
              {
                count: group.size,
                total: total,
                percentage: (totals[nature].zero? ? 0.0 : total.to_f / totals[nature]) * 100
              }
          end
      end
  end

  # @param transactions [Array<Transaction>]
  # @param totals [Hash] - { income: Float, expense: Float }
  # @return [Hash] - { count: Integer, total: Float }
  def merchant_breakdown(transactions, totals)
    transactions
      .group_by(&:merchant)
      .transform_values do |ts|
        ts.group_by(&:nature)
          .each_with_object({}) do |(nature, group), result|
            total = group.sum(&:price)

            result[nature] =
              {
                count: group.size,
                total: total,
                percentage: (totals[nature].zero? ? 0.0 : total.to_f / totals[nature]) * 100
              }
          end
      end
  end

  def investment_breakdown(transactions)
    transactions.group_by(&:merchant)
                .transform_values do |ts|
                  {
                    count: ts.size,
                    total: ts.sum(&:price)
                  }
                end
  end
end
