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
    category_repo = CategoryRepository.new(@database)
    transaction_repo = TransactionRepository.new(@database, category_repo)
    limit_repo = LimitRepository.new(@database, category_repo)
    @bs = BudgetService.new(category_repo, transaction_repo)
    @rs = ReportService.new(category_repo, transaction_repo)
    @ls = LimitService.new(limit_repo)
  end



  # @param argv [Array<String>]
  def run(argv)
    command = argv.shift
    unless command 
      errorise("You must include a command.")
      print_available_commands
      return
    end
    case command.downcase.strip

    when "limit", "l"
      action = argv&.shift
      unless action
        errorise("You must include an action: add | delete | edit | see")
      end

      case action.strip.downcase
      when "set"
        options = OptionWizard.parse_limit_opts(argv)
        amount = argv.shift&.to_f unless argv.empty?
        Commands::Limits::AddLimit.new(@bs, @rs, @ls).run(amount: amount, **options)

      when "see"
        options = OptionWizard.parse_limit_opts(argv)
        Commands::Limits::ViewLimits.new(@bs, @rs, @ls).run(**options)
      when "delete", "del"
        Commands::Limits::DeleteLimit.new(@ls).run
      end


    # adding transactions
    when "transaction", "trans", "t"
      action = argv&.shift
      unless action
        errorise("You must include an action: add | delete | edit")
        return 
      end
      case action.downcase.strip

      when "add", "a"
        options = OptionWizard.parse_transaction_opts(argv)
        price = argv.shift&.to_f unless argv.empty?
        Commands::Transactions::AddTransaction.new(@bs, @rs).run(price: price, **options)
      
      when "delete", "d"
        options = OptionWizard.parse_transaction_delete_and_edit_opts(argv)
        dates = get_date_for_edit_and_delete(argv, options)
        Commands::Transactions::DeleteTransaction.new(@bs, @rs).run(**dates)

      when "edit", "e"
        options = OptionWizard.parse_transaction_delete_and_edit_opts(argv)
        dates = get_date_for_edit_and_delete(argv, options)
        Commands::Transactions::EditTransaction.new(@bs, @rs).run(**dates)
      end

      


    when "earn", "e"
      options = OptionWizard.parse_preset_nature_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::Transactions::AddTransaction.new(@bs, @rs).run(price: price, nature: :income, **options)


    when "spend", "s"
      options = OptionWizard.parse_preset_nature_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::Transactions::AddTransaction.new(@bs, @rs).run(price: price, nature: :expense, **options)
    

    when "invest", "i"
      options = OptionWizard.parse_preset_nature_opts(argv)
      price = argv.shift&.to_f unless argv.empty?
      Commands::Transactions::AddTransaction.new(@bs, @rs).run(price: price, nature: :investment, **options)

    
    # summaries
    when "month", "m"
      options = OptionWizard.parse_summary_opts(argv)
      if argv.empty?
        print_date_error
        return 
      end
      date = PeriodDefiner.define_month(argv.first)
      Commands::Summaries::MonthlySummary.new(@bs, @rs).run(date, **options)


    when "week", "w"
      options = OptionWizard.parse_summary_opts(argv)
      if argv.empty?
        print_date_error
        return
      end
      date = PeriodDefiner.define_week(argv.first)
      Commands::Summaries::WeeklySummary.new(@bs, @rs).run(date, **options)


    when "day", "d"
      options = OptionWizard.parse_summary_opts(argv)
      if argv.empty?
        print_date_error
        return
      end
      date = PeriodDefiner.define_day(argv.first)
      Commands::Summaries::DailySummary.new(@bs, @rs).run(date, **options)
    
    when "year", "y"
      options = OptionWizard.parse_summary_opts(argv)
      if argv.empty?
        print_date_error
        return
      end
      date = PeriodDefiner.define_year(argv.first)
      Commands::Summaries::YearlySummary.new(@bs, @rs).run(date, **options)

    
    when "category", "cat", "c"
      action = argv&.shift
      unless action
        errorise "You must include an action: add | all | delete | edit"
        return
      end
      case action.strip.downcase
      when "add"
        Commands::Categories::AddCategory.new(@bs).run
      when "all"
        Commands::Categories::ShowCategories.new(@bs).run
      when "delete", "del"
        Commands::Categories::DeleteCategory.new(@bs).run
      when "edit"
        Commands::Categories::EditCategory.new(@bs).run
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


  # @param argv [Array<String>]
  # @param options [Hash<Symbol, String>]
  # @return [Hash] => { from:, to: }
  def get_date_for_edit_and_delete(argv, options)
    from = argv.shift
    if from
      from = PeriodDefiner.define_day(from) || Date.today
    else 
      from = Date.today
    end
    
    if options.dig(:to)
      to = PeriodDefiner.define_day(to)
    else
      to = from
    end

    { from: from, to: to }
  end


  # @param string [String]
  def errorise(string)
    puts PASTEL.bright_red.bold(string)
  end

  # @return [String]
  def print_date_error
    errorise("You must include a valid date")
  end

end