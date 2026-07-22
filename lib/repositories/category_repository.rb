class CategoryRepository
  # @param db [SQLite3::Database] - dependency injection for SQLite database
  def initialize(db)
    # @!attribute [SQLite3::Database]
    @db = db
  end

  # @param id [Integer]
  # @return [Category?]
  def find(id)
    row = @db.get_first_row(
      <<~SQL,
        SELECT *
        FROM categories
        WHERE id = ?
      SQL
      [id]
    )

    return nil unless row

    Category.new(
      id: row["id"],
      title: row["title"],
      colour: row["colour"]
    )
  end



  # @param title [String]
  # @return [Category?]
  def find_by_title(title)
    build_category(@db.get_first_row(
      <<~SQL,
        SELECT *
        FROM categories
        WHERE lower(title) = ?
      SQL
      [title.downcase]
    ))
  end

  # @param title [String]
  # @return [Category]
  def search_by_title(title)
    build_category(@db.get_first_row(
      <<~SQL,
        SELECT *
        FROM categories
        WHERE title LIKE ?
      SQL
      ["%#{title}%"]
    ))
  end

  

  # @param category [Category] 
  # @return [Category]
  def save(category)
    if category.id.nil?
      create(category)
    else 
      update(category)
    end
  end



  # Returns all Categories from the database
  # @return [Array<Category>]
  def all
    @db.execute("SELECT * FROM categories").map do |row|
      build_category(row)
    end
  end



  # Deletes a Category record by id, returns true if successful
  # @param id [Integer]
  # @return [Boolean]
  def delete(id)
    @db.execute(
      <<~SQL,
        DELETE FROM categories
        WHERE id = ?
      SQL
      [id]
    )

    return false if @db.changes == 0
    return true
  end

  private
  # @param [Hash] row 
  # @param example: {id => Integer, title => String, colour => String}
  # @return [Category]
  def build_category(row)
    Category.new(
      id: row["id"],
      title: row["title"],
      colour: row["colour"]
    )
  end



  # @param category [Category]
  # @return [Category]
  def update(category)
    @db.execute(
      <<~SQL,
        UPDATE categories
        SET title = ?, colour = ?
        WHERE id = ?
      SQL
      [category.title, category.colour, category.id]
    )
    
    category
  end

   # @param category [Category]
  # @return [Category]
  def create(category)
    @db.execute(
      <<~SQL,
        INSERT INTO categories (title, colour)
        VALUES (?, ?)
      SQL
      [category.title, category.colour]
    )
    category.id = @db.last_insert_row_id
    category
  end

end