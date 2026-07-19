require "tty-prompt"
require "pastel"
require_relative "prompts"
require "date"
require_relative "summary_formatter"
require_relative "../helpers/date_helper"


module Commands

  PROMPT = TTY::Prompt.new
  PASTEL = Pastel.new

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

  class AddTransaction
    # @param bs [BudgetService]
    # @param rs [ReportService]
    def initialize(bs, rs)
      @bs = bs
      @rs = rs
      @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
      @category_prompts = Prompts::CategoryPrompts.new(PROMPT, PASTEL)
    end

    def run(nature: nil, date: nil, price: nil, category: nil, merchant: nil)
      
      category = @bs.find_category_by_title(category) if category
      category ||= get_category
     
      if category.title.strip.downcase == "work"
        merchant = "Omniplex Cinemas"
      end

      nature = nature.to_sym if nature ||= @transaction_prompts.get_nature
      
      merchant ||= get_merchant

      date = DateHelper.parse_arg(date) if date
      date ||= Date.today
      
      price ||= @transaction_prompts.get_price.to_f

      @bs.add_transaction(price: price, category: category, merchant: merchant, nature: nature)
    end

    private
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
        name: PASTEL.bright_green("+Add a category"),
        value: :add_category
      }

      choice = @transaction_prompts.get_category(choices)

      if choice == :add_category
        category = AddCategory.new(@bs).run
      else 
        category = choice
      end
      category
    end

    def get_merchant
       merchants = @bs.merchants 
        merchants << {
          name: "#{PASTEL.bright_green "+New merchant"}",
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
  end

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