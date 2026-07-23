require "tty-prompt"
require "pastel"
require_relative "prompts"
require "date"
require_relative "summary_formatter"
require_relative "../helpers/date_helper"
require_relative "../helpers/period_definer"
require_relative "../models/category"
require "dotenv"

# Any class/command which needs the Helper class should define it in their constructor
module Commands

  PROMPT = TTY::Prompt.new
  PASTEL = Pastel.new

  module Categories

    class AddCategory
      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
        @category_prompts = Prompts::CategoryPrompts.new(PROMPT, PASTEL)
      end

      def run
        title = @category_prompts.get_title
        PROMPT.ok("Creating category #{title}")
        colour = @category_prompts.get_colour
        category = @bs.create_category(title: title, colour: colour)
        PROMPT.ok("Created category #{PASTEL.public_send(colour.to_sym, title) } successfully!")
        category
      end
    end

    class ShowCategories
      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
      end

      def run
        categories = @bs.get_all_categories()
        categories.each do |cat|
          puts "#{PASTEL.bold "ID:"} #{PASTEL.bold cat.id} | #{PASTEL.bold.public_send(cat.colour, cat.title)}"
        end
      end
    end

    class DeleteCategory
      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(bs, transaction_prompts: @transaction_prompts)
      end

      def run
        category = @helper.get_category
        @bs.delete_category(category.id)
      end
    end

    class EditCategory

      # @param bs [BudgetService]
      def initialize(bs)
        @bs = bs
        @category_prompts = Prompts::CategoryPrompts.new(PROMPT, PASTEL)
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(bs, transaction_prompts: @transaction_prompts, category_prompts: @category_prompts)
      end
      
      def run
        category = @helper.get_category
        if @category_prompts.get_wants_to_change_title
          new_title = @category_prompts.get_title
          category.title = new_title
        end

        if @category_prompts.get_wants_to_change_colour
          new_colour = @category_prompts.get_colour
          category.colour = new_colour
        end

        @bs.edit_category(category, new_title: new_title, new_colour: new_colour)
      end
    end
  end

  module Transactions

    class AddTransaction
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @category_prompts = Prompts::CategoryPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(@bs, rs: @rs, transaction_prompts: @transaction_prompts, category_prompts: @category_prompts)
        Dotenv.load
      end

      def run(nature: nil, date: nil, price: nil, category: nil, merchant: nil)
        
        category = @bs.find_category_by_title(category) if category
        category ||= @helper.get_category
      
        if category.title.strip.downcase == "work" && ENV['WORKPLACE']
          merchant = ENV['WORKPLACE']
        end

        nature = nature.to_sym if nature ||= @transaction_prompts.get_nature
        
        merchant ||= @helper.get_recent_merchants(category)

        date = DateHelper.parse_arg(date) if date
        date ||= Date.today
        
        price ||= @transaction_prompts.get_price.to_f

        @bs.add_transaction(price: price, category: category, merchant: merchant, nature: nature)
      end
    end


    class DeleteTransaction
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(@bs, rs: @rs, transaction_prompts: @transaction_prompts)
      end

      def run(from:, to: from)
        return unless from
        choice = @helper.get_transaction_choice_between_dates(from: from, to: to)
        return unless choice
        @bs.delete_transaction(choice.id)
      end
    end

    class EditTransaction
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(@bs, rs: @rs, transaction_prompts: @transaction_prompts)
      end

      def run(from:, to: from)
        return unless from
        choice = @helper.get_transaction_choice_between_dates(from: from, to: to)
        return unless choice
        if @transaction_prompts.get_wants_to_change_category
          new_category = @helper.get_category
        end

        if @transaction_prompts.get_wants_to_change_date
          new_date = PeriodDefiner.define_day(@transaction_prompts.get_date)
        end

        if @transaction_prompts.get_wants_to_change_merchant
          new_merchant = @helper.choose_merchant
        end

        if @transaction_prompts.get_wants_to_change_price
          new_price = @transaction_prompts.get_price
        end

        if @transaction_prompts.get_wants_to_change_nature
          new_nature = @transaction_prompts.get_nature.to_sym
        end

        @bs.edit_transaction(choice.id, new_price: new_price, new_category: new_category, new_date: new_date, new_merchant: new_merchant, new_nature: new_nature)

      end
    end
  end

  module Summaries

    class WeeklySummary
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
      end

      # @param date [Date]
      # @param options [Hash]
      def run(date, options=nil)
        return {} unless date
        summary = @rs.weekly_summary(date)
        last_week_summary = @rs.weekly_summary(date - 7)
        SummaryFormatter.new(summary, last_week_summary, period: :week).format(options: options)
      end
    end

    class MonthlySummary
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
      end

      # @param date [Date]
      # @param options [Hash]
      def run(date, options=nil)
        return {} unless date
        summary = @rs.monthly_summary(date)
        last_month_summary = @rs.monthly_summary(date << 1)
        SummaryFormatter.new(summary, last_month_summary, period: :month).format(options: options)
      end
    end

    class DailySummary
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
      end

      # @param date [Date]
      # @param options [Hash]
      def run(date, options=nil)
        return {} unless date
        summary = @rs.daily_summary(date)
        yesterday_summary = @rs.daily_summary(date - 1)
        SummaryFormatter.new(summary, yesterday_summary, period: :day).format(options: options)
      end
    end
  end


  # A helper class for things like get_category, choose_merchant etc so that they can be used across multiple commands
  class Helpers

    # @param bs [BudgetService]
    # @param transaction_prompts [Prompts::TransactionPrompts]
    # @param category_prompts [Prompts::CategoryPrompts]
    # @param rs [ReportService]
    def initialize(bs, transaction_prompts: nil, category_prompts: nil, rs: nil)
      @bs = bs
      @rs = rs
      @transaction_prompts = transaction_prompts
      @category_prompts = category_prompts
    end

    def get_category
       categories = @bs.get_all_categories

      if categories.empty?
        puts PASTEL.bright_red "No categories found! Create one now."
        AddCategory.new(@bs).run
        categories = @bs.get_all_categories
      end

      choices = categories.map do |cat|
        {
          name: PASTEL.decorate(cat.title, cat.colour.to_sym),
          value: cat
        }
      end
      
      choices << {
        name: PASTEL.bright_green("+ Add a category"),
        value: :add_category
      }

      choice = @transaction_prompts.get_category(choices)

      if choice == :add_category
        category = Categories::AddCategory.new(@bs).run
      else 
        category = choice
      end
      category
    end

    def choose_merchant
      merchants = @bs.merchants.map do |merchant|
        {
        name: PASTEL.public_send(Category::ALLOWED_COLOURS.sample.to_sym).bold(merchant),
        value: merchant
        }
      end

      merchants << {
          name: "#{PASTEL.bright_green.bold "+ New merchant"}",
          value: :add_merchant
      }
      choice = @transaction_prompts.select_merchant(merchants)
      if choice == :add_merchant
        merchant = @transaction_prompts.get_merchant
      else 
        merchant = choice
      end
      merchant
    end

    def get_recent_merchants(category)
      merchants = @bs.recent_merchants(category).map do |merchant|
        {
        name: PASTEL.public_send(Category::ALLOWED_COLOURS.sample.to_sym).bold(merchant),
        value: merchant
        }
      end
      merchants << {
        name: "#{PASTEL.bright_cyan.bold "- Other"}",
        value: :other
      }
      merchants << {
        name: "#{PASTEL.bright_green.bold "+ New merchant"}",
        value: :add_merchant
      }

      choice = @transaction_prompts.select_merchant(merchants)
      if choice == :other
        choose_merchant
      elsif choice == :add_merchant
        @transaction_prompts.get_merchant
      end
    end

    # @return [Transaction | nil]
    def get_transaction_choice_between_dates(from:, to:)
    transactions = @bs.find_transactions_between(from: from, to: to)
    if transactions.empty?
        puts PASTEL.bright_red.bold "No transactions found in this period."
        return nil
    end
    choices = transactions.map do |t|
        {
          name: "#{t.date} | #{t.category.title} | #{t.nature} | #{t.merchant} | #{t.price}",
          value: t
        }
      end

    choice = @transaction_prompts.get_transaction(choices)
    pp choice
    return choice
    end
  end

  


end