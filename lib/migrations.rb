require "sqlite3"

class Migrations

  # @param db [SQLite3::Database]
  def self.migrate(db)
    create_categories(db)
    create_transactions(db)
  end

  def self.clear_transactions(db)
    db.execute(
      <<~SQL,
        DELETE FROM transactions
      SQL
    )
  end

  def self.clear_categories(db)
    db.execute(
    <<~SQL,
      DELETE FROM transactions
    SQL
    )
  end

  def self.clear_database(db)
    clear_transactions(db)
    clear_categories(db)
  end


  private 
  # @param db [SQLite3::Database]
  def self.create_categories(db)
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL UNIQUE,
        colour TEXT NOT NULL
      );
    SQL
  end

  # @param db [SQLite3::Database]
  def self.create_transactions(db)
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY,
        price DECIMAL NOT NULL,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        merchant TEXT,
        nature TEXT,

        FOREIGN_KEY category_id
          REFERENCES categories(id)
          ON DELETE CASCADE
      );
    SQL
  end
end