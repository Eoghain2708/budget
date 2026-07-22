require "sqlite3"
require "date"
class TransactionRepository
  
  # @param db [SQLite3::Database]
  # @param category_repo [CategoryRepository]
  def initialize(db, category_repo)
    # @!attribute [SQLite3::Database]
    @db = db
    # @!attribute [CategoryRepository]
    @category_repo = category_repo
  end

  # @param transaction [Transaction]
  # @return [Transaction]
  def save(transaction)
    transaction.id == nil ? create(transaction) : update(transaction)
  end

  # @param id [Integer]
  # @return [Transaction]
  def find(id)
    row = @db.get_first_row(
      <<~SQL,
        SELECT *
        FROM transactions
        WHERE id = ?
      SQL
      [id]
    )

    return nil unless row

    build_transaction(row)
  end

  # @param category [Category]
  # @return [Array<Transaction>]
  def find_by_category(category)
    rows = @db.execute(
      <<~SQL,
        SELECT * FROM transactions
        WHERE category_id = ?
      SQL
      [category.id]
    )

    return [] unless rows
    rows.map do |row|
      build_transaction(row)
    end
  end

  # @param merchant [String]
  # @return [Array<Transaction>]
  def find_by_merchant(merchant)
    rows = @db.execute(
      <<~SQL,
        SELECT * FROM transactions
        WHERE merchant LIKE ?
      SQL
      [merchant]
    )

    return [] unless rows
    rows.map do |row|
      build_transaction(row)
    end
  end

  # @param date [Date]
  # @return [Array<Transaction>]
  def find_by_date(date)
    rows = @db.execute(
      <<~SQL,
        SELECT * FROM transactions
        WHERE date = ?
      SQL
      [date.to_s]
    )

    rows.map do |row|
      build_transaction(row)
    end
  end


  # @param from [Date]
  # @param to [Date] - if not provided, defaults to Date.today
  # @return [Array<Transaction>]
  def find_between(from: nil, to: Date.today)
    rows = @db.execute(
      <<~SQL,
        SELECT * FROM transactions
        WHERE date >= ?
        AND date <= ?
      SQL
      [from.iso8601, to.iso8601]
    )

    rows.map do |row|
      build_transaction(row)
    end
  end

  # @param id [Integer]
  # @return [Boolean]
  def delete(id)
    @db.execute(
      <<~SQL,
        DELETE FROM transactions
        WHERE id = ?;
      SQL
      [id]
    )

    @db.changes > 0
  end

  # @return [Array<Transaction>]
  def all
    rows = @db.execute("SELECT * FROM transactions")
    return [] unless rows
     
    rows.map do |row|
      build_transaction(row)
    end

    rows
  end

  # @return [Array<String>]
  def merchants
    rows = @db.execute(
      <<~SQL,
        SELECT DISTINCT merchant
        FROM transactions
        ORDER BY merchant;
      SQL
    )
    rows.map do |row|
      row["merchant"]
    end
  end


  # @param category [Category]
  # @return [Array<String>] string of merchants associated with that category
  def get_recent_merchants(category)
    rows = @db.execute(
      <<~SQL,
        SELECT DISTINCT merchant FROM transactions
        WHERE category_id = ?
        ORDER BY date DESC
        LIMIT 5;
      SQL
      [category.id]
    )

    rows.map do |row|
      row["merchant"]
    end
  end

  
  private
  # @param row [Hash]
  # = {
  # id => Integer,
  # price => Float,
  # date => String
  # category_id => Integer,
  # merchant => String,
  # nature => Symbol
  # 
  # }
  # @return [Transaction]
  def build_transaction(row)
    category = @category_repo.find(row["category_id"])

    Transaction.new(
      id: row["id"],
      price: row["price"],
      date: Date.parse(row["date"]),
      category: category,
      merchant: row["merchant"],
      nature: row["nature"].to_sym

    )
  end


  # @param transaction [Transaction]
  # @return [Transaction]
  def create(transaction)
    @db.execute(
      <<~SQL,
        INSERT INTO transactions (price, date, category_id, merchant, nature)
        VALUES (?, ?, ?, ?, ?)
      SQL
      [transaction.price, transaction.date.iso8601, transaction.category.id, transaction.merchant, transaction.nature.to_s]
    )
    transaction.id = @db.last_insert_row_id
    transaction
  end

  # @param transaction [Transaction]
  # @return [Transaction]
  def update(transaction)
    @db.execute(
      <<~SQL,
        UPDATE transactions
        SET price = ?, date = ?, category_id = ?, merchant = ?, nature = ?
        WHERE id = ?
      SQL
      [transaction.price, transaction.date.iso8601, transaction.category.id, transaction.merchant, transaction.nature.to_s, transaction.id]
    )

    transaction
  end
end