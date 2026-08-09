class Limit
  attr_accessor :id, :category, :merchant, :amount, :period_type

  ALLOWED_PERIOD_TYPES = %i[daily weekly monthly yearly]
  # @param id [Integer]
  # @param category [Category]
  # @param merchant [String]
  # @param amount [Float]
  # @param period_type [Symbol]
  def initialize(id: nil, category: nil, merchant: nil, amount: nil, period_type: nil)
    raise ArgumentError, 'Limit amount must be specified' unless amount
    raise ArgumentError, 'Period (e.g week, month) must be specified' unless period_type
    unless ALLOWED_PERIOD_TYPES.include?(period_type)
      raise ArgumentError,
            "Invalid period type: must be in #{ALLOWED_PERIOD_TYPES}"
    end
    raise ArgumentError, 'Either category or merchant must be specified' unless category || merchant
    raise ArgumentError, 'Limit cannot apply to both a merchant and a category' if category && merchant

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

  def category?
    !@category.nil?
  end

  def merchant?
    !@merchant.nil?
  end

  def type
    return :category if category?

    :merchant
  end

  def get_period_string
    return 'week' if weekly?
    return 'day' if daily?
    return 'month' if monthly?

    'year' if yearly?
  end

  def ==(other)
    other.is_a?(Limit) && @id == other.id
  end

  alias eql? ==

  def hash
    @id.hash
  end
end
