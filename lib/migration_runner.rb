require 'sqlite3'

class MigrationRunner
  MIGRATIONS_DIR = File.expand_path('../db/migrations', __dir__)

  # @param db [SQLite3::Database]
  def self.run(db)
    ensure_schema_migrations_table(db)
    applied_versions = fetch_applied_versions(db)
    migration_files = Dir.glob(File.join(MIGRATIONS_DIR, '*.sql')).sort
    migration_files.each do |file_path|
      file_name = File.basename(file_path)
      version = file_name.split('_').first
      next if applied_versions.include?(version)

      apply_migration(db, version, file_path)
    end
  end

  def self.ensure_schema_migrations_table(db)
    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version TEXT PRIMARY KEY,
        applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    SQL
  end

  def self.fetch_applied_versions(db)
    rows = db.execute('SELECT version FROM schema_migrations')
    rows.map { |r| r['version'] }
  end

  def self.apply_migration(db, version, file_path)
    sql_content = File.read(file_path)
    db.transaction do
      db.execute_batch(sql_content)

      db.execute('INSERT INTO schema_migrations (version) VALUES (?)', [version])
    end
    puts "Applied migration: #{File.basename(file_path)}"
  rescue StandardError => e
    puts "Failed to apply migration #{version}: #{e.message}"
    raise e
  end
end
