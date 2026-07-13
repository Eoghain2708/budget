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
        ["Income", PASTEL.green(summary[:total_income])],
        ["Expense", PASTEL.bright_red(summary[:total_expense])],
        ["Net gain", summary[:net_gain].positive? ? PASTEL.bright_green(summary[:net_gain]) : PASTEL.red(summary[:net_gain])]
      ]
    )
    puts "#{PASTEL.bold message}: #{PASTEL.yellow.bold(summary[:from].strftime("%A %d %B %Y"))} => #{PASTEL.yellow.bold(summary[:to].strftime("%A %d %B %Y"))}"
    puts PASTEL.bright_cyan.bold summary_table.render(:unicode)
  end

  # @param summary [Hash] 
  # @example => { from: Date, to: Date, transactions: Array<Transaction>, transaction_count: Integer, total_expense: Float, total_income: Float, net_gain: Float,
  # category_breakdown: { count: Integer, total: Float },
  # merchant_breakdown: Hash } }
  def self.format_categories(summary)
    rows = summary[:category_breakdown].map do |category, data|
      [
        PASTEL.public_send(category.colour.to_sym, category.title),
        data[:count],
        Kernel.format("£%.2f", data[:total])
      ]
    end

    table = TTY::Table.new(
      header: ["Category", "Transactions", "Total"],
      rows: rows
    )

    puts PASTEL.bright_magenta.bold table.render(:unicode)
  end


  # @param summary [Hash]
  def self.format_merchants(summary)
    rows = []
    summary[:merchant_breakdown].each do |merchant, natures|
      natures.each do |nature, data|
        rows << [
          merchant,
          nature.to_s.capitalize,
          data[:count],
          Kernel.format("£%.2f", data[:total])
        ]
      end
    end
    table = TTY::Table.new( 
      header: ["Merchant", "Nature", "Transactions", "Total"],
      rows: rows
    )

    puts PASTEL.blue table.render(:unicode)
  end
end