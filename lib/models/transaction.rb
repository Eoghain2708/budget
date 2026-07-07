require "date"

class Transaction
  attr_reader :id 
  # @return [Float]
  attr_reader :price
  # @return [Date]
  attr_reader :date
  # @return [Category]
  attr_reader :category
  # @return [String]
  attr_reader :merchant

  # @param id - unique identifier
  # @param price: [Float] - amount spent in transaction
  # @param date: [Date] - date of transaction (today by default)
  # @param category: [Category] - category of transaction
  # @param merchant: [String] - unspecified by default
  # @return [Transaction]
  def initialize(id: nil, price:, date: Date.today, category:, merchant: "unspecified")
    @price = price
    @date = date
    @category = category
    @merchant = merchant
  end
end