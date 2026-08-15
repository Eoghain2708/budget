class RecurringTransaction
  attr_accessor :id, :category, :merchant, :init_date, :period_type, :next_due, :price, :nature
  ALLOWED_PERIOD_TYPES = [:daily, :weekly, :monthly, :yearly]
  ALLOWED_NATURES = [:expense, :income, :investment]
  # @param id [Integer]
  # @param category [Category]
  # @param merchant [String]
  # @param init_date [Date]
  # @param period_type [Symbol]
  # @param price [Float]
  # @param nature [Symbol]
  def initialize(id: nil, category: nil, merchant: nil, init_date: nil, period_type: nil, price: nil, nature: nil, next_due: nil)
    raise ArgumentError, "Price needs to be specified" unless price && price >= 0
    raise ArgumentError, "Merchant and category needs to be specified" unless merchant && category
    raise ArgumentError, "Date of first payment needs to be specified" unless init_date
    raise ArgumentError, "Valid period type needs to be specified" unless period_type && ALLOWED_PERIOD_TYPES.include?(period_type)
    raise ArgumentError, "Valid nature must be specified" unless nature && ALLOWED_NATURES.include?(nature)
    @id = id
    @category = category
    @merchant = merchant
    @init_date = init_date
    @period_type = period_type
    @price = price
    @next_due = next_due.nil? ? init_date : next_due
    @nature = nature
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

  def update_next_due
    @next_due = calculate_next_due(period_type, next_due)
  end

  def expense?
    @nature == :expense
  end

  def income?
    @nature == :income
  end

  def investment?
    @nature == :investment
  end

  def ==(other)
    other.is_a?(RecurringTransaction) && @id == other.id
  end

  alias eql? ==

  def hash
    id.hash
  end
  
  def get_period_string
    return 'week' if weekly?
    return 'day' if daily?
    return 'month' if monthly?
    return 'year' if yearly?
  end

  private
  
  # @param period_type [Symbol]
  # @param date [Date]
  def calculate_next_due(period_type, date)
    return date + 1 if period_type == :daily
    return date + 7 if period_type == :weekly

    if period_type == :monthly
      next_month = date >> 1
      last_day = Date.new(next_month.year, next_month.month, -1).day
      day = [@init_date.day, last_day].min
      return Date.new(next_month.year, next_month.month, day)
    end

    if period_type == :yearly
      next_year = date >> 12
      last_day = Date.new(next_year.year, next_year.month, -1).day
      day = [@init_date.day, last_day].min
      return Date.new(next_year.year, next_year.month, day)
    end
  end
end