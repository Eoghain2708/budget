CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL UNIQUE,
        colour TEXT NOT NULL
);