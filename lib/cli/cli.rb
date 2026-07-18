require_relative "../budget"
require_relative "prompts"
require_relative "commands"
require_relative "../helpers/period_definer"

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
    when "transaction", "trans"
      Commands::AddTransaction.new(@bs, @rs).run
    when "earn"
      Commands::AddTransaction.new(@bs, @rs).run(nature: :income)
    when "spend"
      Commands::AddTransaction.new(@bs, @rs).run(nature: :expense)
    when "month"
      date = PeriodDefiner.define_month(argv.first)
      Commands::MonthlySummary.new(@bs, @rs).run(date)
    when "week"
      date = PeriodDefiner.define_week(argv.first)
      Commands::WeeklySummary.new(@bs, @rs).run(date)
    when "day"
      date = PeriodDefiner.define_day(argv.first)
      Commands::DailySummary.new(@bs, @rs).run(date)
    when "addcat", "category", "cat"
      Commands::AddCategory.new(@bs).run
    when "allcategories"
      Commands::ShowCategories.new(@bs).run
    else 
      "Invalid command"
    end
  end


end