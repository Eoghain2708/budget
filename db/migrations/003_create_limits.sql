CREATE TABLE IF NOT EXISTS limits (
  id INTEGER PRIMARY KEY,
  category_id INTEGER,
  merchant TEXT,
  period_type TEXT NOT NULL,
  amount DECIMAL NOT NULL,

  FOREIGN KEY (category_id)
    REFERENCES categories(id)
    ON DELETE CASCADE
);