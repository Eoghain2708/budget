require_relative "../budget"
require_relative "prompts"
require_relative "commands"
require_relative "../helpers/period_definer"
require_relative "option_wizard"
require "pastel"

class CLI
  PASTEL = Pastel.new
  def initialize()
    @database = Database.connection()
    Migrations.migrate(@database)
    category_repo = CategoryRepository.new(@database)
    transaction_repo = TransactionRepository.new(@database, category_repo)
    @bs = BudgetService.new(category_repo, transaction_repo)
    @rs = ReportService.new(category_repo, transaction_repo)
  end



  # @param argv [Array<String>]
  def run(argv)
    command = argv.shift

    case command.downcase.strip

    # adding transactions
    when "transaction", "trans"
      action = argv&.shift
      case action.downcase.strip
      when "add"
        options = OptionWizard.parse_transaction_opts(argv)
        price = argv.shift&.to_f unless argv.empty?
        Commands::AddTransaction.new(@bs, @rs).run(price: price, **options)
      
      when "delete"
        options = OptionWizard.parse_transaction_delete_opts(argv)
        from = argv.shift
        from = PeriodDefiner.define_day(from)
        if options.dig(:to)
          to = PeriodDefiner.define_day(to)
        else 
          to = from
        end
        
        Commands::DeleteTransaction.new(@bs, @rs).run(from: from, to: to)
      end
      


    when "earn"
      options = OptionWizard.parse_preset_nature_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::AddTransaction.new(@bs, @rs).run(price: price, nature: :income, **options)


    when "spend"
      options = OptionWizard.parse_preset_nature_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::AddTransaction.new(@bs, @rs).run(price: price, nature: :expense, **options)

    
    # summaries
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
      date = PeriodDefiner.define_day(argv.first)
      Commands::DailySummary.new(@bs, @rs).run(date, **options)

    
    when "category", "cat"
      action = argv&.shift
      case action.strip.downcase
      when "add"
        Commands::AddCategory.new(@bs).run
      when "all"
        Commands::ShowCategories.new(@bs).run
      when "delete", "del"
        Commands::DeleteCategory.new(@bs).run
      when "edit"
        Commands::EditCategory.new(@bs).run
      else 
        print_invalid_action_for_categories
      end

    when "help"
      print_available_commands
    
    else 
      puts PASTEL.bright_red.bold "Invalid command"
      print_available_commands
    end
  end



  private
  def print_invalid_action_for_categories
    puts PASTEL.bright_red.bold("Invalid action: available actions: budget category #{PASTEL.green.bold "add"}, #{PASTEL.bright_blue.bold "all"}, #{PASTEL.bright_red.bold "delete"}")
  end

  def print_available_commands
    puts PASTEL.bold "Available commands:"
    puts "-" * 20
    puts "#{PASTEL.bold "Category: "} #{PASTEL.bright_green "budget category"}"
    puts "#{PASTEL.bold "Transaction: "} #{PASTEL.bright_magenta "budget transaction | budget earn | budget spend"}"
    puts "#{PASTEL.bold "Summary "} #{PASTEL.bright_blue "budget day | budget month | budget week"}"
  end

end