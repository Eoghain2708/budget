require_relative "../budget"
require_relative "prompts"
require_relative "commands"

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
    when "transaction", "trans", "tran", "t"
      Commands::AddTransaction.new(@bs, @rs).run
    when "from", "f"
      summary_between(argv)
    when "month"
      monthly_summary(argv)
    when "week"
      weekly_summary(argv)
    when "day"
      daily_summary(argv)
    when "addcat", "category", "cat"
      Commands::AddCategory.new(@bs).run
    when "allcategories"
      show_all_categories
    else 
      "Invalid command"
    end
  end


end