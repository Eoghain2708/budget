class LimitRepository

  # @param db [SQLite3::Database]
  # @param category_repo [CategoryRepository]
  def initialize(db, category_repo)
    # @!attribute [SQLite3::Database]
    raise ArgumentError, "db must exist" unless db
    raise ArgumentError, "category repository must exist" unless category_repo
    @db = db

    @crepo = category_repo
  end

  # @param id [Integer]
  # @return [Limit | nil]
  def find(id)
    row = @db.get_first_row <<~SQL
      SELECT * FROM limits 
      WHERE id = ?
    SQL
    [id]

    return nil unless row
    build_limit(row)
  end


  # @param id [Integer]
  # @return [Boolean]
  def delete(id)
    @db.execute <<~SQL
      DELETE * FROM limits
      WHERE id = ?
    SQL
    [id]
  end

  # @param category [Category]
  # @return [Array<Limit> | nil]
  def find_by_category(category)
    rows = @db.execute <<~SQL
      SELECT * FROM limits
      WHERE category_id = ?
    SQL
    [category.id]

    return nil unless rows 
    
    rows.map do |r|
      build_limit(r)
    end
  end

  # @param merchant [String]
  # @return [Array<Limit> | nil]
  def find_by_merchant(merchant)
    rows = @db.execute <<~SQL
      SELECT * FROM limits
      WHERE LOWER(merchant) = ?
    SQL
    [merchant.downcase]

    return nil unless rows

    rows.map do |r|
      build_limit(r)
    end
  end

  # @param merchant [String]
  # @param period_type [Symbol]
  # @return [Array<Limit> | nil]
  def find_by_merchant_and_period_type(merchant, period_type:)
    raise ArgumentError, "Period type must be supplied" unless period_type
    rows = @db.execute <<~SQL
      SELECT * FROM limits
      WHERE LOWER(merchant) = ?
      AND period_type = ?
    SQL
    [merchant.downcase, period_type.to_s]

    return nil unless rows

    rows.map { |r| build_limit(r) }
  end

  # @param category [Category]
  # @param period_type [Symbol]
  # @return [Array<Limit> | nil]
  def find_by_category_and_period_type(category, period_type:)
    raise ArgumentError, "Period type must be supplied" unless period_type
    rows = @db.execute <<~SQL
      SELECT * FROM limits
      WHERE category_id = ? 
      AND period_type = ?
    SQL
    [category.id, period_type.to_s]

    return nil unless rows

    rows.map { |r| build_limit(r)}
  end

  # @param period_type [Symbol]
  # @return [Array<Limit> | nil]
  def find_by_period_type(period_type)
    rows = @db.execute <<~SQL
      SELECT * FROM limits
      WHERE period_type = ?
    SQL
    [period_type.to_s]

    return nil unless rows

    rows.map { |r| build_limit(r) }
  end

  # @return [Array<Limit> | nil]
  def all
    rows = @db.execute("SELET * FROM limits")
    return nil unless rows
    rows.map { |r| build_limit(r) }
  end

  # @param limit [Limit]
  def save(limit)
    limit.id == nil ? create(limit) : save(limit)
  end


  

  private
  # @param row [Hash]
  # @example {
  # id: Integer,
  # category_id: Integer | nil,
  # merchant: String | nil,
  # period: String,
  # amount: Float,
  # period: String
  # }
  def build_limit(row)
    category = @crepo.find(row["category_id"])

    Limit.new(
      id: row["id"],
      category: category,
      merchant: row["merchant"],
      amount: row["amount"],
      period_type: row["period_type"].to_sym
    )
  end

  # @param limit [Limit]
  # @return [Limit]
  def create(limit)
    @db.execute <<~SQL
      INSERT INTO limits (category_id, merchant, period_type, amount)
      VALUES (?, ?, ?, ?)
    SQL
    [limit.category.id, limit.merchant, limit.period_type, limit.amount]

    limit.id = @db.last_insert_row_id
    limit
  end

  # @param limit [Limit]
  # @return [Limit]
  def update(limit)
    @db.execute <<~SQL
      INSERT INTO limits (category_id, merchant, period_type, amount)
      VALUES (?, ?, ?, ?)
      WHERE id = ?
    SQL
    [limit.category.id, limit.merchant, limit.period_type, limit.amount, limit.id]

    limit
  end

  
end