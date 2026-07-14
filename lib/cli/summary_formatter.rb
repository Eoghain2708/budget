require "pastel"
require "date"
require "tty-table"

class SummaryFormatter
  PASTEL = Pastel.new


  # @param summary [Hash]
  # @param last_week_summary [Hash]
  def initialize(summary, last_week_summary)
    @summary = summary
    @prev = last_week_summary
  end


  def format(message="Report for period")
    divide
    puts "#{PASTEL.bold message}: #{PASTEL.yellow.bold(@summary[:from].strftime("%A %d %B %Y"))} => #{PASTEL.yellow.bold(@summary[:to].strftime("%A %d %B %Y"))}"
    print_one_line_greeting
    format_summary(message)
    format_categories()
    format_merchants()
  end

 
  # @param message [String] 
  # @return [Void]
  def format_summary(message="Report for period")
    summary_table = TTY::Table.new(
      [
        ["   Transactions   ", PASTEL.bold(@summary[:transaction_count])],
        ["   Income   ", colourise_money(@summary[:total_income])],
        ["   Expense   ", colourise_money_negative(@summary[:total_expense])],
        ["   Net gain   ", colourise_money(@summary[:net_gain], signed: true)]
      ]
    )

    puts ""
    puts PASTEL.bold("General Summary")
    puts PASTEL.bright_cyan.bold summary_table.render(:unicode, alignments: [:left, :right])
    divide
  end


  # @example => { from: Date, to: Date, transactions: Array<Transaction>, transaction_count: Integer, total_expense: Float, total_income: Float, net_gain: Float,
  # category_breakdown: { count: Integer, total: Float },
  # merchant_breakdown: Hash } }
  def format_categories
    rows = @summary[:category_breakdown].map do |category, natures|
      totals = totals_by_nature(natures)
      net_result = totals[:income][:total] - totals[:expense][:total]
      total = net_result.positive? ? colourise_money_positive(net_result, signed: true) : colourise_money_negative(net_result, signed: true)
      [
        PASTEL.public_send(category.colour.to_sym, category.title),
        "#{colourise_money_positive(totals[:income][:total])} (#{PASTEL.bold totals[:income][:percentage]&.round(2) || "0"}%)",
        "#{colourise_money_negative(totals[:expense][:total])} (#{PASTEL.bold totals[:expense][:percentage]&.round(2) || "0"}%)",
        total
      ]
    end

    table = TTY::Table.new(
      header: ["   Category   ", "   Income   ", "   Expense   ", "   Total   "],
      rows: rows
    )


    puts PASTEL.bold("Category Breakdown")
    puts PASTEL.bright_magenta.bold table.render(:unicode, alignments: [:left, :left, :left, :right])
    divide
  end

  def format_merchants
    rows = @summary[:merchant_breakdown].map do |merchant, natures|
      totals = totals_by_nature(natures)
      net_result = totals[:income][:total] - totals[:expense][:total]
      total = net_result.positive? ? colourise_money_positive(net_result, signed: true) : colourise_money_negative(net_result, signed: true)
      [
        PASTEL.white.bold(merchant),
        "#{colourise_money_positive(totals[:income][:total])} (#{PASTEL.bold totals[:income][:percentage]&.round(2) || "0"}%)",
        "#{colourise_money_negative(totals[:expense][:total])} (#{PASTEL.bold totals[:expense][:percentage]&.round(2) || "0"}%)",
        total
      ]
    end

    table = TTY::Table.new(
      header: ["   Merchant   ", "   Income   ", "   Expense   ", "   Total   ", ],
      rows: rows
    )

    puts PASTEL.bold("Merchant Breakdown")
    puts PASTEL.bright_blue.bold table.render(:unicode, alignments: [:left, :left, :left, :right])
    divide
  end

  private 
  # @param number [Float]
  # @return [String] - formatted money String
  def money(number, signed: false)
    return PASTEL.white.bold.dim "£0.00" if number.zero?
    if signed
     result = number.positive? ? Kernel.format("+£%.2f", number.abs) : Kernel.format("-£%.2f", number.abs)
     return result
    end
    return Kernel.format("£%.2f", number.abs)
  end

  # @param number [Float]
  # @return [String]
  def colourise_money_positive(number, signed: false)
    return PASTEL.green.bold("#{money(number, signed: signed)}")
  end

  def colourise_money_negative(number, signed: false)
    return PASTEL.red.bold(money(number, signed: signed))
  end

  def colourise_money(number, signed: false)
    if number > 0
      colourise_money_positive(number, signed: signed)
    elsif number < 0
      colourise_money_negative(number, signed: signed)
    else 
      money(number)
    end
  end

  def totals_by_nature(natures)
    {
      income: natures.fetch(:income, { count: 0, total: 0 }),
      expense: natures.fetch(:expense, { count: 0, total: 0 })
    }
  end

  def divide
   puts ""
   puts ""
  end

  def print_one_line_greeting
    previous_earnings = @prev.dig(:net_gain)
    puts PASTEL.bold("Net gain: #{colourise_money(@summary[:net_gain])}")
    puts PASTEL.bright_green.bold "You earned more than you spent for this period!" if @summary[:net_gain].positive?
    puts PASTEL.bright_red.bold "You spent more than you earned for this period!" if @summary[:net_gain].negative?
    puts PASTEL.white.bold "You spent and earned equally for this period!" if @summary[:net_gain].zero?
    puts PASTEL.bold("Last week's earnings: #{previous_earnings}")
  end
end