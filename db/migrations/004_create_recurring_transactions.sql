CREATE TABLE IF NOT EXISTS recurring_transactions (
  id INTEGER PRIMARY KEY,
  category_id INTEGER NOT NULL,
  merchant STRING NOT NULL,
  init_date TEXT NOT NULL,
  nature TEXT NOT NULL,
  next_due TEXT NOT NULL,
  period_type TEXT NOT NULL,

  FOREIGN KEY (category_id)
  REFERENCES categories(id)
);