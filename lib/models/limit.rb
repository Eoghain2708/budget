class Limit
  attr_accessor :id, :category, :merchant, :amount, :period_type
  ALLOWED_PERIOD_TYPES = [:daily, :weekly, :monthly, :yearly]
  # @param id [Integer]
  # @param category [Category]
  # @param merchant [String]
  # @param amount [Float]
  # @param period_type [Symbol]
  def initialize(id: nil, category: nil, merchant: nil, amount: nil, period_type: nil)
    raise ArgumentError, "Limit amount must be specified" unless amount
    raise ArgumentError, "Period (e.g week, month) must be specified" unless period_type
    raise ArgumentError, "Invalid period type: must be in #{ALLOWED_PERIOD_TYPES.to_s}" unless ALLOWED_PERIOD_TYPES.include?(period_type)
    raise ArgumentError, "Either category or merchant (or both) must be specified" unless category || merchant

    @id = id
    @category = category
    @merchant = merchant
    @amount = amount
    @period_type = period_type
  end

  def daily?
    @period_type == :daily
  end

  def weekly?
    @period_type == :weekly
  end

  def monthly?
    @period_type == :monthly
  end

  def yearly?
    @period_type == :yearly
  end
end