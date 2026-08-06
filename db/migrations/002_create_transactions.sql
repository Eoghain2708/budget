CREATE TABLE IF NOT EXISTS transactions (
  id INTEGER PRIMARY KEY,
  price DECIMAL NOT NULL,
  date TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  merchant TEXT,
  nature TEXT,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);