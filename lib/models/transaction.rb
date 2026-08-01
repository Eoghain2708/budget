require "date"

class Transaction
  attr_accessor :id 
  # @return [Float]
  attr_accessor :price
  # @return [Date]
  attr_accessor :date
  # @return [Category]
  attr_accessor :category
  # @return [String]
  attr_accessor :merchant
  # @return [Symbol]
  attr_accessor :nature

  # @param id - unique identifier
  # @param price [Float] - amount spent in transaction
  # @param date [Date] - date of transaction (today by default)
  # @param category [Category] - category of transaction
  # @param merchant [String] - unspecified by default
  # @param nature [Symbol] - :expense, :income, :investment
  # @return [Transaction]
  def initialize(id: nil, price:, date: Date.today, category:, merchant: "unspecified", nature:)
    unless nature == :income || nature == :expense || nature == :investment
      raise ArgumentError, "Invalid nature"
    end
    raise ArgumentError, "Invalid Price" unless price.positive?
    raise ArgumentError, "Invalid Date" if date > Date.today
    @id = id
    @price = price
    @date = date
    @category = category
    @merchant = merchant
    @nature = nature
    @recurring = recurring
  end

  def ==(other)
    other.is_a?(Transaction) && @id == other.id
  end

  alias eql? ==

  def hash
    @id.hash
  end

  def income?
    @nature == :income
  end

  def expense?
    @nature == :expense
  end

  def investment?
    @nature == :investment
  end

  def counts_towards_net_gain?
    income? || expense?
  end
end