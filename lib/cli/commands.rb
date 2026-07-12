require "tty-prompt"
require "pastel"
require_relative "prompts"
require "date"

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
      @bs.create_category(title: title, colour: colour)
      PROMPT.ok("Created category #{PASTEL.public_send(colour.to_sym, title) } successfully!")
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

    def run
      categories = @bs.get_all_categories.map do |cat|
        {
          name: PASTEL.decorate(cat.title, cat.colour.to_sym),
          value: cat
        }
      end

      nature = @transaction_prompts.get_nature.to_sym
      category = @transaction_prompts.get_category(categories)
      if category.title.strip.downcase == "work"
        merchant = "Omniplex Cinemas"
      else 
        merchant = @transaction_prompts.get_merchant
      end
      
      amount = @transaction_prompts.get_price.to_f

      @bs.add_transaction(price: amount, category: category, merchant: merchant, nature: nature)
    end
  end

  class WeeklySummary
    # @param bs [BudgetService]
    # @param rs [ReportService]
    def initialize(bs, rs)
      @bs = bs
      @rs = rs
    end

    # @param date [String]
    def run(date)
      return {} unless date
      summary = @rs.weekly_summary(Date.parse(date))
      pp summary
    end
  end


end