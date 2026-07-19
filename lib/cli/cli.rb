require_relative "../budget"
require_relative "prompts"
require_relative "commands"
require_relative "../helpers/period_definer"
require_relative "option_wizard"

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
      options = OptionWizard.parse_transaction_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::AddTransaction.new(@bs, @rs).run(price: price, **options)
    when "earn"
      options = OptionWizard.parse_preset_nature_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::AddTransaction.new(@bs, @rs).run(price: price, nature: :income, **options)
    when "spend"
      options = OptionWizard.parse_preset_nature_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::AddTransaction.new(@bs, @rs).run(price: price, nature: :expense, **options)
    when "month"
      options = OptionWizard.parse_summary_opts(argv)
      date = PeriodDefiner.define_month(argv.first)
      Commands::MonthlySummary.new(@bs, @rs).run(date, **options)
    when "week"
      options = OptionWizard.parse_summary_opts(argv)
      date = PeriodDefiner.define_week(argv.first)
      Commands::WeeklySummary.new(@bs, @rs).run(date, **options)
    when "day"
      options = OptionWizard.parse_summary_opts(argv)
      pp options
      date = PeriodDefiner.define_day(argv.first)
      Commands::DailySummary.new(@bs, @rs).run(date, **options)
    when "addcat", "category", "cat"
      Commands::AddCategory.new(@bs).run
    when "allcategories"
      Commands::ShowCategories.new(@bs).run
    else 
      "Invalid command"
    end
  end


end