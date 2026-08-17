require "pastel"

module FormattingHelper
  PASTEL = Pastel.new

  # @param number [Float]
  # @param signed [Boolean] + or - depending on negative or positive (default false)
  # @param symbol [Boolean] currency symbol used (default true)
  # @return [String] - formatted money String
  def self.money(number, signed: false, symbol: true)
    return PASTEL.white.bold.dim '£0.00' if number.zero?

    if signed && symbol
      result = number.positive? ? Kernel.format('+£%.2f', number.abs) : Kernel.format('-£%.2f', number.abs)
      return result
    end

    if signed && !symbol
      result = number.positive? ? Kernel.format('+%.2f', number.abs) : Kernel.format('-%.2f', number.abs)
      return result
    end

    Kernel.format('%.2f', number.abs)
  end

  # @param number [Float]
  # @param signed [False]
  # @return [String]
  def self.colourise_money_positive(number, signed: false, symbol: true)
    PASTEL.green.bold("#{money(number, signed: signed, symbol: symbol)}")
  end

  # @param number [Float]
  # @param signed [False]
  # @return [String]
  def self.colourise_money_negative(number, signed: false, symbol: true)
    PASTEL.red.bold(money(number, signed: signed, symbol: symbol))
  end

  # @param number [Float]
  # @param signed [Boolean] - whether the resulting string will return a + or - depending on number.
  # @return [String]
  def self.colourise_money(number, signed: false, symbol: true)
    if number > 0
      colourise_money_positive(number, signed: signed, symbol: symbol)
    elsif number < 0
      colourise_money_negative(number, signed: signed, symbol: symbol)
    else
      money(number)
    end
  end

  # @param invested [Float]
  # @param current [Float]
  def self.colourise_position(invested, current)
    if invested > current
      colourise_money_negative(current)
    end

    if invested == current
      return PASTEL.bold.white(current)
    end

    return colourise_money_positive(current)
  end
end