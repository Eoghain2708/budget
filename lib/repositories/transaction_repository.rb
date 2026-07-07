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
    transaction.id.nil ? create(transaction) : update(transaction)
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

  end

  # @param category_id [Integer]
  # @return [Array<Transaction>]
  def find_by_category(category_id)
    rows = @db.execute(
      <<~SQL,
        SELECT * FROM transactions
        WHERE category_id = ?
      SQL
      [category_id]
    )

    return [] unless rows
    rows.map do |row|
      build_transaction(row)
    end
  end

  # @param id [Integer]
  # @return [Boolean]
  def delete(id)
    @db.execute(
      <<~SQL,
        DELETE FROM categories
        WHERE id = ?
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

  private
  # @param row [Hash]
  # = {
  # id => Integer,
  # price => Float,
  # date => String
  # category_id => Integer,
  # merchant => String
  # }
  # @return [Transaction]
  def self.build_transaction(row)
    category = @category_repo.find(row["category_id"])

    Transaction.new(
      id: row["id"],
      price: row["price"],
      date: Date.parse(row["date"]),
      category: category,
      merchant: row["merchant"]
    )
  end


  # @param transaction [Transaction]
  # @return [Transaction]
  def create(transaction)
    @db.execute(
      <<~SQL,
        INSERT INTO transactions (price, date, category_id, merchant)
        VALUES (?, ?, ?, ?)
      SQL
      [transaction.price, transaction.date.to_s, transaction.category.id, transaction.merchant]
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
        SET price = ?, date = ?, category_id = ?, merchant = ?
        WHERE id = ?
      SQL
      [transaction.price, transaction.date.to_s, transaction.category.id, transaction.merchant, transaction.id]
    )

    transaction
  end
end