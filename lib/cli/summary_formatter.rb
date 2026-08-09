require 'pastel'
require 'date'
require 'tty-table'

class SummaryFormatter
  PASTEL = Pastel.new
  ALLOWED_PERIODS = %i[day week month year].freeze

  # @param summary [Hash]
  # @param previous_summary [Hash] - previous relative to the current summary i.e, if a weekly summary is passed, previous_summary
  # will be the last week's summary, if a monthly summary is passed, previous will be last month, etc.
  # @param period [Symbol] :day, :week, :month, :year
  def initialize(summary, previous_summary, period:)
    raise ArgumentError, 'Invalid Period' unless ALLOWED_PERIODS.include?(period)

    @summary = summary
    @prev = previous_summary
    @period = period
  end

  # @param message [String] defaulted to a reasonable value but can be changed - "Report for week/day/month"
  # @param options [Hash] - options for formatting. Can be nil and indeed is by default. Use &.dig for all option parsing rather than accessing directly.
  def format(message = "Report for #{@period}", options: nil)
    divide
    puts "#{PASTEL.bold message}: #{PASTEL.yellow.bold(@summary[:from].strftime('%A %d %B %Y'))} => #{PASTEL.yellow.bold(@summary[:to].strftime('%A %d %B %Y'))}"
    if options&.dig(:inv)
      format_investments unless @summary&.dig(:investment_breakdown).empty?
      return
    end
    print_net_gain_at_glance
    return if options&.dig(:short)

    format_summary(message)
    format_categories unless @summary&.dig(:category_breakdown).empty?
    format_merchants unless @summary&.dig(:merchant_breakdown).empty?
    format_investments unless @summary&.dig(:investment_breakdown).empty?
  end

  # @param message [String]
  # @return [Void]
  def format_summary(_message = "Report for #{@period}")
    summary_table = TTY::Table.new(
      rows: [
        ['   Transactions   ', PASTEL.bold.white(@summary[:transaction_count]),
         PASTEL.bold.white(@prev[:transaction_count])],
        ['   Income   ', colourise_money(@summary[:total_income]), colourise_money(@prev[:total_income])],
        ['   Expense   ', colourise_money_negative(@summary[:total_expense]),
         colourise_money_negative(@prev[:total_expense])],
        ['   Net gain   ', colourise_money(@summary[:net_gain], signed: true),
         colourise_money(@prev[:net_gain], signed: true)]
      ],
      header: [' Data ', " This #{@period} ", " Previous #{@period} "]
    )

    puts ''
    puts PASTEL.bold('General Summary')
    puts PASTEL.bright_cyan.bold summary_table.render(:unicode, alignments: %i[left right right])
    divide
  end

  # @example => { from: Date, to: Date, transactions: Array<Transaction>, transaction_count: Integer, total_expense: Float, total_income: Float, net_gain: Float,
  # category_breakdown: { count: Integer, total: Float },
  # merchant_breakdown: Hash } }
  def format_categories
    rows = @summary[:category_breakdown].map do |category, natures|
      totals = totals_by_nature(natures)
      row_data = row_data(totals)

      [
        PASTEL.public_send(category.colour.to_sym, category.title),
        "#{row_data[:income]} #{row_data[:income_percentage]}",
        "#{row_data[:expense]} #{row_data[:expense_percentage]}",
        row_data[:total]
      ]
    end

    table = TTY::Table.new(
      header: ['   Category   ', '   Income   ', '   Expense   ', '   Total   '],
      rows: rows
    )

    puts PASTEL.bold('Category Breakdown')
    puts PASTEL.bright_magenta.bold table.render(:unicode, alignments: %i[left left left right])
    divide
  end

  def format_merchants
    rows = @summary[:merchant_breakdown].map do |merchant, natures|
      totals = totals_by_nature(natures)
      row_data = row_data(totals)
      [
        PASTEL.white.bold(merchant),
        "#{row_data[:income]} #{row_data[:income_percentage]}",
        "#{row_data[:expense]} #{row_data[:expense_percentage]}",
        row_data[:total]
      ]
    end

    table = TTY::Table.new(
      header: ['   Merchant   ', '   Income   ', '   Expense   ', '   Total   '],
      rows: rows
    )

    puts PASTEL.bold('Merchant Breakdown')
    puts PASTEL.bright_blue.bold table.render(:unicode, alignments: %i[left left left right])
    divide
  end

  def format_investments
    rows = @summary[:investment_breakdown].map do |merchant, data|
      [
        PASTEL.white.bold(merchant),
        PASTEL.white.bold(data[:count]),
        PASTEL.white.bold(colourise_money(data[:total]))
      ]
    end

    table = TTY::Table.new(
      header: ['   Stock   ', '   Transactions   ', "   Total Invst'd   "],
      rows: rows
    )

    puts PASTEL.bold.bright_yellow('INVESTMENTS')
    divide(1)
    puts PASTEL.bold.magenta(" - Total invested: #{colourise_money(@summary[:total_investment])}")
    puts PASTEL.bright_yellow.bold table.render(:unicode, alignments: %i[left right right])
  end

  private

  # @param number [Float]
  # @param signed [Boolean]
  # @return [String] - formatted money String
  def money(number, signed: false)
    return PASTEL.white.bold.dim '£0.00' if number.zero?

    if signed
      result = number.positive? ? Kernel.format('+£%.2f', number.abs) : Kernel.format('-£%.2f', number.abs)
      return result
    end
    Kernel.format('£%.2f', number.abs)
  end

  # @param number [Float]
  # @param signed [False]
  # @return [String]
  def colourise_money_positive(number, signed: false)
    PASTEL.green.bold("#{money(number, signed: signed)}")
  end

  # @param number [Float]
  # @param signed [False]
  # @return [String]
  def colourise_money_negative(number, signed: false)
    PASTEL.red.bold(money(number, signed: signed))
  end

  # @param number [Float]
  # @param signed [Boolean] - whether the resulting string will return a + or - depending on number.
  # @return [String]
  def colourise_money(number, signed: false)
    if number > 0
      colourise_money_positive(number, signed: signed)
    elsif number < 0
      colourise_money_negative(number, signed: signed)
    else
      money(number)
    end
  end

  # @param natures [Hash]
  # @return [Hash]
  def totals_by_nature(natures)
    {
      income: natures.fetch(:income, { count: 0, total: 0 }),
      expense: natures.fetch(:expense, { count: 0, total: 0 })
    }
  end

  def divide(num = 2)
    num.times do
      puts ''
    end
  end

  # @return [Void]
  def print_net_gain_at_glance
    puts PASTEL.bold.bright_green(" - In: #{colourise_money_positive(@summary[:total_income])}")
    puts PASTEL.bold.bright_red(" - Out: #{colourise_money_negative(@summary[:total_expense])}")
    puts PASTEL.bold.bright_cyan(" - Gain: #{colourise_money(@summary[:net_gain], signed: true)}")
    divide 1
    puts "#{PASTEL.bold.underline(" - Gain vs last #{@period}: ")}" + " #{PASTEL.bold(compare_net_gain_to_previous)}"
    divide 1
  end

  # @return [Float] - percentage difference between current and previous
  def compare_net_gain_to_previous
    colourise_money(@summary&.dig(:net_gain) - @prev&.dig(:net_gain), signed: true)
  end

  def compare_net_gain_to_previous_percentage
    compare_by_percentages(@summary&.dig(:net_gain), @prev&.dig(:net_gain))
  end

  def compare_spending_to_previous
    compare_by_percentages(@summary&.dig(:total_expense), @prev&.dig(:total_expense))
  end

  def compare_income_to_previous
    compare_by_percentages(@summary&.dig(:total_income), @prev&.dig(:total_income))
  end

  # @param comparee [Float] - the main number being examined
  # @param comparator [Float] - the number comparee will be compared against
  # @return [Float] - the percentage difference between comparee and comparator
  def compare_by_percentages(comparee, comparator)
    return 0.0 if comparator == 0

    (((comparee - comparator).to_f / comparator.abs) * 100).round(2)
  end

  # @param num [Float | Integer]
  # @return [String]
  def colourise_or_dash_money(num, negative: false)
    return PASTEL.bold.dim('-') if num.zero?

    return colourise_money_negative(num) if negative

    colourise_money_positive(num)
  end

  # @param totals [Hash]
  # => { income: { count: Integer, total: Float, percentage: Float }, expense: { count: Integer, total: Float, percentage: Float } }
  # if count/total are zero then percentage will not exist in this Hash
  def row_data(totals)
    net_result = totals[:income][:total] - totals[:expense][:total]
    total = if net_result.positive?
              colourise_money_positive(net_result,
                                       signed: true)
            else
              colourise_money_negative(net_result,
                                       signed: true)
            end
    income = colourise_or_dash_money(totals[:income][:total])
    income_percentage = totals[:income][:percentage].nil? ? '' : "(#{totals[:income][:percentage].round(2)}%)"
    expense = colourise_or_dash_money(totals[:expense][:total], negative: true)
    expense_percentage = totals[:expense][:percentage].nil? ? '' : "(#{totals[:expense][:percentage].round(2)}%)"

    {
      net_result: net_result,
      total: total,
      income: income,
      income_percentage: income_percentage,
      expense: expense,
      expense_percentage: expense_percentage
    }
  end
end
