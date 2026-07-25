
module TestFactories
  def category(id: 1, title: "Food", colour: "red")
    Category.new(id: id, title: title, colour: colour)
  end

  def transaction(
    id: 1,
    price: 10.0,
    date: Date.today,
    category: category,
    merchant: "Lidl",
    nature: :expense
  )
    Transaction.new(
      id: id,
      price: price,
      date: date,
      category: category,
      merchant: merchant,
      nature: nature
    )
  end
end

class FakeCategoryRepository
  attr_reader :saved, :deleted_id, :find_by_title_arg, :search_by_title_arg

  def initialize(all: [], find_by_title: nil, search_by_title: nil)
    @all = all
    @find_by_title_result = find_by_title
    @search_by_title_result = search_by_title
  end

  def save(category)
    @saved = category
    category
  end

  def delete(category_id)
    @deleted_id = category_id
    true
  end

  def all
    @all
  end

  def find_by_title(title)
    @find_by_title_arg = title
    @find_by_title_result
  end

  def search_by_title(title)
    @search_by_title_arg = title
    @search_by_title_result
  end
end

class FakeTransactionRepository
  attr_reader :saved, :deleted_id, :find_id, :find_between_args, :find_by_date_arg, :recent_merchants_arg

  def initialize(find: nil, between: [], by_date: nil, merchants: [], recent_merchants: [])
    @find_result = find
    @between_result = between
    @by_date_result = by_date
    @merchants_result = merchants
    @recent_merchants_result = recent_merchants
  end

  def save(transaction)
    @saved = transaction
    transaction
  end

  def delete(id)
    @deleted_id = id
    true
  end

  def find(id)
    @find_id = id
    @find_result
  end

  def find_between(from:, to:)
    @find_between_args = [from, to]
    @between_result
  end

  def find_by_date(date)
    @find_by_date_arg = date
    @by_date_result
  end

  def merchants
    @merchants_result
  end

  def get_recent_merchants(category)
    @recent_merchants_arg = category
    @recent_merchants_result
  end
end