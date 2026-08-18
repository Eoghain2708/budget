require_relative 'commands'

module Commands
  # A helper class for things like get_category, choose_merchant etc so that they can be used across multiple commands
  class Helpers
    PROMPT = TTY::Prompt.new
    PASTEL = Pastel.new
    # @param bs [BudgetService]
    # @param transaction_prompts [Prompts::TransactionPrompts]
    # @param category_prompts [Prompts::CategoryPrompts]
    # @param rs [ReportService]
    def initialize(bs: nil, transaction_prompts: nil, category_prompts: nil, limit_prompts: nil, rs: nil, ls: nil)
      @bs = bs
      @rs = rs
      @ls = ls
      @transaction_prompts = transaction_prompts
      @category_prompts = category_prompts
      @limit_prompts = limit_prompts
    end

    # @param attribute [String]
    # @param previous [String]
    # @param new [String]
    # @return [String]
    def previous_and_new(previous, new, attribute = nil)
      return "#{attribute}: #{PASTEL.bold.bright_red previous} => #{PASTEL.bold.bright_green new}" if attribute

      puts "#{PASTEL.bold.bright_red previous} => #{PASTEL.bold.bright_green new}"
    end

    def get_category
      categories = @bs.get_all_categories

      if categories.empty?
        puts PASTEL.bright_red 'No categories found! Create one now.'
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
        name: PASTEL.bright_green('+ Add a category'),
        value: :add_category
      }

      choice = @transaction_prompts.get_category(choices)

      if choice == :add_category
        Categories::AddCategory.new(@bs).run
      else
        choice
      end
    end

    def choose_merchant
      merchants = @bs.merchants.map do |merchant|
        {
          name: PASTEL.public_send(Category::ALLOWED_COLOURS.sample.to_sym).bold(merchant),
          value: merchant
        }
      end

      merchants << {
        name: "#{PASTEL.bright_green.bold '+ New merchant'}",
        value: :add_merchant
      }
      choice = @transaction_prompts.select_merchant(merchants)
      choice = @transaction_prompts.get_merchant if choice == :add_merchant
      choice
    end

    def choose_from_recent_merchants(category)
      merchants = @bs.recent_merchants(category).map do |merchant|
        {
          name: PASTEL.public_send(Category::ALLOWED_COLOURS.sample.to_sym).bold(merchant),
          value: merchant
        }
      end
      merchants << {
        name: "#{PASTEL.bright_cyan.bold '- Other'}",
        value: :other
      }
      merchants << {
        name: "#{PASTEL.bright_green.bold '+ New merchant'}",
        value: :add_merchant
      }

      choice = @transaction_prompts.select_merchant(merchants)
      if choice == :other
        choose_merchant
      elsif choice == :add_merchant
        @transaction_prompts.get_merchant
      else
        choice
      end
    end

    # @return [Transaction | nil]
    def get_transaction_choice_between_dates(from:, to:)
      transactions = @bs.find_transactions_between(from: from, to: to)
      if transactions.empty?
        puts PASTEL.bright_red.bold 'No transactions found in this period.'
        return nil
      end

      choices = transactions.map do |t|
        formatted = formatted_transaction(t)
        {
          name: [
            formatted[:date],
            formatted[:category],
            formatted[:nature],
            formatted[:merchant],
            formatted[:price]
          ].join(' | '),
          value: t
        }
      end

      @transaction_prompts.get_transaction(choices)
    end

    def choose_limit
      limits = @ls.all_limits
      puts PASTEL.bright_red 'No limits found.' if limits.empty?
      choices = limits&.map do |limit|
        area = limit.category&.title || limit.merchant

        area_width = 20
        period_width = 8
        amount_width = 10

        area_display =
          if limit.category
            PASTEL.public_send(limit.category.colour).decorate(area)
          else
            PASTEL.dim.decorate(area)
          end

        {
          name: "#{area_display.ljust(area_width)} | " \
                "#{limit.period_type.to_s.upcase.ljust(period_width)} | " \
                "#{limit.amount.to_s.rjust(amount_width)}",
          value: limit
        }
      end
      @limit_prompts.get_limit(choices)
    end

    # @param transactions [Array<Transaction>]
    def find_transactions_to_ignore(transactions)
      choices = transactions&.map do |t|
        {
          name: "#{t.merchant} | #{t.nature} | #{t.price} | #{t.date}",
          value: t
        }
      end

      @transaction_prompts.find_transactions_to_ignore(choices)
    end

    # @param t [Transaction]
    # @return [Hash<Symbol, String>]
    def formatted_transaction(t)
      date = t.date.to_s.ljust(12)
      date = PASTEL.bold.bright_yellow(date)
      category = t.category.title.ljust(15)
      category = PASTEL.bold.public_send(t.category.colour.to_sym, category)
      merchant = t.merchant&.ljust(15)
      merchant = PASTEL.bold.public_send(Category::ALLOWED_COLOURS.sample.to_sym, merchant)
      price = t.price.to_s.rjust(10)
      if t.expense?
        nature = 'Exp.'.ljust(5)
        nature = PASTEL.bold.bright_red(nature)
        price = PASTEL.bold.bright_red(price)
      elsif t.income?
        nature = 'Inc.'.ljust(5)
        nature = PASTEL.bold.bright_green(nature)
        price = PASTEL.bold.bright_green(price)
      elsif t.investment?
        nature = 'Inv.'.ljust(5)
        nature = PASTEL.bold.bright_magenta(nature)
        price = PASTEL.bold.bright_magenta(price)
      end

      {
        date: date,
        category: category,
        merchant: merchant,
        nature: nature,
        price: price
      }
    end
  end
end
