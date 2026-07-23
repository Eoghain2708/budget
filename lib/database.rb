require "sqlite3"
require "fileutils"

# Database class used to create or retrieve a connection with the SQLite database
class Database

  APP_DIR = File.join(Dir.home, ".local", "share", "budget")
  DB_PATH = File.join(APP_DIR, "budget.db")

  def self.connection
    FileUtils.mkdir_p(APP_DIR)

    # [SQLite3::Database]
    @connection ||= begin
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true
    db
    end
  end
end
