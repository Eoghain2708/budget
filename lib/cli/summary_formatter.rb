require "pastel"
require "date"
require "tty-table"

module SummaryFormatter
  PASTEL = Pastel.new



  def self.format(summary, message="Report for period")
    format_summary(summary, message)
    format_categories(summary)
    format_merchants(summary)
  end

  # @param summary [Hash] 
  # @param message [String] 
  # @return [Void]
  def self.format_summary(summary, message="Report for period")
    summary_table = TTY::Table.new(
      [
        ["Transactions", summary[:transaction_count]],
        ["Income", PASTEL.green("+#{summary[:total_income]}")],
        ["Expense", PASTEL.bright_red("-#{summary[:total_expense]}")],
        ["Net gain", summary[:net_gain].positive? ? PASTEL.bright_green("+#{summary[:net_gain]}") : PASTEL.red("-#{summary[:net_gain]}")]
      ]
    )
    puts "#{PASTEL.bold message}: #{PASTEL.yellow.bold(summary[:from].strftime("%A %d %B %Y"))} => #{PASTEL.yellow.bold(summary[:to].strftime("%A %d %B %Y"))}"

    puts PASTEL.bold("General Summary")
    puts PASTEL.bright_cyan.bold summary_table.render(:unicode)
    puts PASTEL.bold("-" * 40)
  end

  # @param summary [Hash] 
  # @example => { from: Date, to: Date, transactions: Array<Transaction>, transaction_count: Integer, total_expense: Float, total_income: Float, net_gain: Float,
  # category_breakdown: { count: Integer, total: Float },
  # merchant_breakdown: Hash } }
  def self.format_categories(summary)
  income = []
  expense = []
    summary[:category_breakdown].each do |category, natures|
      natures.each do |nature, data|
        row = [
        PASTEL.public_send(category.colour.to_sym, category.title),
        data[:count],
        Kernel.format("£%.2f", data[:total])
        ]

        income << row if nature == :income
        expense << row if nature == :expense
      end
    end

    income_table = TTY::Table.new(
      header: ["Category", "Transactions", "Total"],
      rows: income
    )

    expense_table = TTY::Table.new(
      header: ["Category", "Transactions", "Total"],
      rows: expense
    )

    puts PASTEL.bold("Incomes by category")
    puts PASTEL.bright_green.bold income_table.render(:unicode)
    puts PASTEL.bold("-" * 40)
    puts PASTEL.bold("Expenses by category")
    puts PASTEL.bright_red.bold expense_table.render(:unicode)

  end


  # @param summary [Hash]
  def self.format_merchants(summary)
    income = []
    expense = []
    summary[:merchant_breakdown].each do |merchant, natures|
      natures.each do |nature, data|
        row = [
          merchant,
          data[:count],
          Kernel.format("£%.2f", data[:total])
        ]

        income << row if nature == :income
        expense << row if nature == :expense
      end
    end
    
    income_table = TTY::Table.new(
      header: ["Merchant", "Transactions", "Total"],
      rows: income
    )

    expense_table = TTY::Table.new(
      header: ["Merchant", "Transactions", "Total"],
      rows: expense
    )
    
    puts PASTEL.bold("Incomes by merchant")
    puts PASTEL.bright_green.bold income_table.render(:unicode)
    puts PASTEL.bold("-" * 40)
    puts PASTEL.bold("Expenses by merchant")
    puts PASTEL.bright_red.bold expense_table.render(:unicode)
  end
end