require "sqlite3"

# Database class used to create or retrieve a connection with the SQLite database
class Database
  def self.connection
    # [SQLite3::Database]
    @connection ||= begin
    db = SQLite3::Database.new("db/budget.db")
    db.results_as_hash = true
    db
    end
  end
end
