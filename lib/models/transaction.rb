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