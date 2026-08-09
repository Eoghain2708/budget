require 'pastel'
require_relative '../helpers/colours'

class LimitFormatter
  PASTEL = Pastel.new
  MAX_PROGRESS_BAR_LENGTH = 25
  # @param limits [Array<Limit>]
  # @param summaries [Array<Hash>]
  def format(limits, summaries)
    limits.each do |l|
      summary = define_summary(l, summaries)
      breakdown = define_data_area(l, summary)
      total = get_totals(l, breakdown)
      percentage = ((total.to_f / l.amount.to_f) * 100).round(2)
      print_formatted_limit(l, total, percentage)
    end
  end

  # @param limit [Limit]
  # @param summaries [Array<Hash>]
  def define_summary(limit, summaries)
    return summaries.first if summaries.size == 1

    daily, weekly, monthly, yearly = summaries
    return daily if limit.daily?
    return weekly if limit.weekly?
    return monthly if limit.monthly?

    yearly if limit.yearly?
  rescue StandardError => e
    raise IndexError("List of summaries does not include each period, #{e}")
  end

  # @param limit [Limit]
  # @param summary [Hash]
  # @return [Hash]
  # => either summary[:merchant_breakdown] or summary[:category_breakdown]
  # depending on if **limit** is category or merchant based
  def define_data_area(limit, summary)
    return summary[:category_breakdown] if limit.category?

    summary[:merchant_breakdown] if limit.merchant?
  rescue StandardError => e
    warn 'Invalid summary provided - does not include :merchant_breakdown or :category_breakdown'
    puts e.message
  end

  # @param limit [Limit]
  # @param breakdown [Hash] => category or merchant breakdown
  # @return [Hash] => Spending data
  def get_totals(limit, breakdown)
    expense_minus_income(limit, breakdown, limit_type: limit.type)
  end

  private

  # @param limit [Limit]
  # @param breakdown [Hash]
  # @param limit_type [Symbol] => :merchant, :category
  def expense_minus_income(limit, breakdown, limit_type:)
    if limit_type == :merchant
      return 0 unless breakdown&.dig(limit.merchant)

      expenses = breakdown&.dig(limit.merchant, :expense, :total) || 0
      income = breakdown&.dig(limit.merchant, :income, :total) || 0

      return expenses - income
    end

    if limit_type == :category
      return 0 unless breakdown&.dig(limit.category)

      expenses = breakdown&.dig(limit.category, :expense, :total) || 0
      income = breakdown&.dig(limit.category, :income, :total) || 0

      return expenses - income
    end
    0
  end

  # @param limit [Limit]
  # @param total [Float]
  # @param percentage [Float]
  def print_formatted_limit(limit, total, percentage)
    divide
    if limit.merchant?
      puts "#{PASTEL.bold.public_send(Colours::ALLOWED_COLOURS.sample.to_sym,
                                      limit.merchant)} - #{PASTEL.bold limit.period_type.to_s.upcase}"
    else
      puts "#{PASTEL.bold.public_send(limit.category.colour,
                                      limit.category.title)} - #{PASTEL.bold limit.period_type.to_s.upcase}"
    end
    info = "#{print_over_under(total, limit.amount, percentage)}"
    puts "#{info.ljust(55)} #{print_progress_bar(total, limit.amount, percentage)}"
    space
  end

  def print_over_under(total, limit_amount, percentage)
    if total > limit_amount
      return PASTEL.bold.bright_red("£#{total}/#{PASTEL.bold.white("£#{limit_amount}")} (#{percentage}%)")
    end

    if percentage > 75
      return PASTEL.bold.bright_red("£#{total}/#{PASTEL.bold.white("£#{limit_amount}")} (#{percentage}%)")
    end

    if percentage > 50
      return PASTEL.bold.bright_yellow("£#{total}/#{PASTEL.bold.white("£#{limit_amount}")} (#{percentage}%)")
    end

    PASTEL.bold.bright_green("£#{total}/#{PASTEL.bold.white("£#{limit_amount}")} (#{percentage}%)")
  end

  def print_progress_bar(total, limit_amount, percentage)
    bar_length = (percentage / 4).ceil
    remainder = MAX_PROGRESS_BAR_LENGTH - bar_length
    return PASTEL.bold.red("#{'▋' * MAX_PROGRESS_BAR_LENGTH} LIMIT EXCEEDED") if total > limit_amount

    return PASTEL.bold.bright_red('▋' * bar_length) + PASTEL.dim('▋' * remainder) if percentage > 75

    return PASTEL.bold.yellow('▋' * bar_length) + PASTEL.dim('▋' * remainder) if percentage > 50

    return "#{PASTEL.dim('▋' * MAX_PROGRESS_BAR_LENGTH)} #{PASTEL.green.bold 'EARNED MORE THAN SPENT'}" if total < 0

    PASTEL.bold.bright_green('▋' * bar_length) + PASTEL.dim('▋' * remainder)
  end

  def divide(number = 27)
    puts '--' * number
  end

  def space(number = 1)
    number.times { puts '' }
  end
end
