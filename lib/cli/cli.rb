require_relative "../budget"

class CLI

 
  def initialize()
    database = Database.connection()
    Migrations.migrate(database)
    category_repo = CategoryRepository.new(database)
    transaction_repo = TransactionRepository.new(database, category_repo)
    @bs = BudgetService.new(category_repo, transaction_repo)
    @rs = ReportService.new(category_repo, transaction_repo)
  end


  # @param argv [Array<String>]
  def run(argv)
    


    command = argv.shift

    case command.downcase.strip
    when "out", "spend", "s"
      expense_transaction(argv)
    when "in", "earn", "i"
      income_transaction(argv)
    when "from", "f"
      summary_between(argv)
    when "month"
      monthly_summary(argv)
    when "week"
      weekly_summary(argv)
    when "day"
      daily_summary(argv)
    when "addcat", "category", "cat"
      add_category(argv)
    when "allcategories"
      show_all_categories
    end
  end

  # @param argv [Array<String>]
  def add_category(argv)
    category_name = "Fuel"
    category_colour = "magenta"
    @bs.create_category(title: category_name, colour: category_colour)
  end

  def show_all_categories
    categories = @bs.get_all_categories
    categories.each do |category|
      p category.title
      p category.colour
      p category.id
    end
  end

end