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

  attr_accessor :nature

  # @param id - unique identifier
  # @param price [Float] - amount spent in transaction
  # @param date [Date] - date of transaction (today by default)
  # @param category [Category] - category of transaction
  # @param merchant [String] - unspecified by default
  # @param nature [Symbol] - :expense or :income
  # @return [Transaction]
  def initialize(id: nil, price:, date: Date.today, category:, merchant: "unspecified", nature: :expense)
    unless nature == :income || nature == :expense
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
  end
end