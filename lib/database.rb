require "sqlite3"
require "fileutils"

# Database class used to create or retrieve a connection with the SQLite database
class Database

  DB_PATH = File.expand_path("../../db/budget.db", __dir__)

  def self.connection
    dirname = File.dirname(DB_PATH)
    FileUtils.mkdir_p(dirname)
    # [SQLite3::Database]
    @connection ||= begin
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true
    db
    end
  end
end
