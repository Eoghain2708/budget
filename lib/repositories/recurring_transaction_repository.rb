require_relative "../../lib/models/recurring_transaction"
require "date"

class RecurringTransactionRepository
  # @param db [SQLite3::Database]
  # @param t_repo [TransactionRepository]
  # @param c_repo [CategoryRepository]
  def initialize(db, t_repo, c_repo)
    @db = db
    @t_repo = t_repo 
    @c_repo = c_repo
  end

  def find(id)
    row = @db.execute(<<~SQL,
      SELECT * FROM recurring_transactions
      WHERE id = ?
    SQL
    [id]
    )
    build_recurring_transaction(row)
  end

  # @param id [Integer]
  # @return [Boolean]
  def delete(id)
    @db.execute(<<~SQL,
      DELETE FROM recurring_transactions
      WHERE id = ?
    SQL
                [id])

    return true if @db.changes > 0

    false
  end

  # @return [Array<RecurringTransaction> | nil]
  def all
    rows = @db.execute <<~SQL
      SELECT * FROM recurring_transactions
    SQL

    rows.map { |r| build_recurring_transaction(r) }
  end

  # @param recurring [RecurringTransaction]
  def save(recurring)
    recurring.id.nil? ? create(recurring) : update(recurring)
  end

  # @param category [Category]
  # @param merchant [String]
  # @param period_type [Symbol]
  # @param price [Float] - includes anything below and up to
  # @param init_date [Date]
  # @param next_due [Date]
  # @param unprocessed [Boolean]
  def find_by_attrs(category: nil, merchant: nil, period_type: nil, price: nil, init_date: nil, next_due: nil, unprocessed: nil, nature: nil, id: nil)
    sql = "SELECT * FROM recurring_transactions"
    conditions = []
    params = []

    if category
      conditions << 'category_id = ?'
      params << category.id
    end

    if merchant
      conditions << 'merchant = ?'
      params << merchant
    end

    if period_type
      conditions << 'period_type = ?'
      params << period_type.to_s
    end

    if price
      conditions << 'price <= ?'
      params << price
    end

    if init_date
      conditions << 'init_date = ?'
      params << init_date.iso8601
    end

    if next_due
      conditions << "next_due = ?"
      params << next_due.iso8601
    end

    if unprocessed == true
      conditions << "next_due <= ?"
      params << Date.today.iso8601
    end

    if unprocessed == false
      conditions << "next_due > ?"
      params << Date.today.iso8601
    end

    if nature
      conditions << "nature = ?"
      params << nature.to_s.downcase
    end

    if id
      conditions << "id = ?"
      params << id
    end

    sql << ' WHERE ' << conditions.join(' AND ') unless conditions.empty?
    rows = @db.execute(sql, params)
    rows.map { |r| build_recurring_transaction(r) }
  end






  # @param recurring [RecurringTransaction]
  # @return [Transaction]
  def build_transaction_from_recurring(recurring)
    Transaction.new(
        category: recurring.category,
        merchant: recurring.merchant,
        date: recurring.next_due,
        nature: recurring.nature,
        price: recurring.price
    )
  end

  private
  def build_recurring_transaction(row)
    category = @c_repo.find(row["category_id"])

    RecurringTransaction.new(
      id: row["id"],
      category: category,
      merchant: row["merchant"],
      init_date: Date.parse(row["init_date"]),
      period_type: row["period_type"].to_sym,
      price: row["price"],
      nature: row["nature"].to_sym
    )
  end

  # @param recurring [RecurringTransaction]
  # @return [RecurringTransaction]
  def create(recurring)
    @db.execute(
      <<~SQL,
        INSERT INTO recurring_transactions (category_id, merchant, init_date, nature, next_due, period_type, price)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      SQL
      [
      recurring.category.id, recurring.merchant, recurring.init_date.iso8601, 
      recurring.nature.to_s, recurring.next_due.iso8601, recurring.period_type.to_s, recurring.price
      ]
    )
    recurring.id = @db.last_insert_row_id
    recurring
  end

  # @param recurring [RecurringTransaction]
  # @return [RecurringTransaction]
  def update(recurring)
    @db.execute(
      <<~SQL,
        UPDATE recurring_transactions
        SET category_id = ?, merchant = ?, init_date = ?, nature = ?, next_due = ?, period_type = ?, price = ?
        WHERE id = ?
      SQL
      [recurring.category.id, recurring.merchant, recurring.init_date.iso8601, 
      recurring.nature.to_s, recurring.next_due.iso8601, recurring.period_type.to_s, recurring.price, recurring.id]
    )

    recurring
  end
end