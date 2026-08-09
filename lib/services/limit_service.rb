class LimitService
  # @param limits [LimitRepository]
  def initialize(limits)
    raise ArgumentError, 'Limit Repository must be supplied' unless limits

    @limits = limits
  end

  # @param category [Category]
  # @param merchant [String]
  # @param amount [Float]
  # @param period_type [Symbol]
  # @return [Limit]
  def create_limit(category:, merchant:, amount:, period_type:)
    limit = Limit.new(
      category: category,
      merchant: merchant,
      amount: amount,
      period_type: period_type
    )

    @limits.save(limit)
  end

  # @param limit [Limit] - the limit to be edited
  # @param new_category [Category]
  # @param new_merchant [String]
  # @param new_amount [Float]
  # @param new_period_type [Symbol]
  # @return [Limit]
  def edit_limit(limit, new_category: nil, new_merchant: nil, new_amount: nil, new_period_type: nil)
    limit.category = new_category if new_category
    limit.new_merchant = new_merchant if new_merchant
    limit.new_amount = new_amount
    limit.new_period_type = new_period_type if new_period_type

    @limits.save(limit)
  end

  # @return [Boolean]
  def delete_limit(limit)
    @limits.delete(limit.id)
  end

  # @return [Array<Limit>]
  def all_limits
    @limits.all
  end

  # @param period_type [Symbol]
  def find_by_period_type(period_type)
    raise ArgumentError, 'Period type must be supplied' unless period_type

    @limits.find_by_period_type(period_type)
  end

  def find_by_category(category)
    @limits.find_by_category(category)
  end

  def find_by_category_and_period_type(category, period_type:)
    @limits.find_by_category_and_period_type(category, period_type: period_type)
  end

  def find_by_merchant(merchant)
    @limits.find_by_merchant(merchant)
  end

  def find_by_merchant_and_period_type(merchant, period_type:)
    @limits.find_by_merchant_and_period_type(merchant, period_type: period_type)
  end

  def find_by_attrs(category: nil, merchant: nil, period_type: nil)
    @limits.find_by_attrs(category: category, merchant: merchant, period_type: period_type)
  end
end
