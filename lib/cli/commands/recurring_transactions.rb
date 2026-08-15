require_relative 'commands'
require "irb"
require "date"

module Commands
  module RecurringTransactions
    PROMPT = TTY::Prompt.new
    PASTEL = Pastel.new

    class AddRecurring
      # @param bs [BudgetService]
      # @param rs [ReportService]
      # @param rts [RecurringTransactionService]
      def initialize(bs, rs, rts)
        @bs = bs
        @rs = rs
        @rts = rts
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @category_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @recurring_prompts = Prompts::RecurringTransactionPrompts.new(PROMPT, PASTEL)
        @helper = Commands::Helpers.new(bs: @bs, rs: @rs, category_prompts: @category_prompts, transaction_prompts: @transaction_prompts)
      end

      def run(category: nil, merchant: nil, init_date: nil, price: nil, nature: nil, period_type: nil)
        category = @bs.find_category_by_title(category) if category
        category ||= @helper.get_category

        merchant ||= @helper.choose_merchant

        init_date ||= @recurring_prompts.get_init_date
        init_date = PeriodDefiner.define_day(init_date)

        period_type = period_type&.to_s || @recurring_prompts.get_period_type
        price ||= @recurring_prompts.get_price(period_type); price = price.to_f

        nature = nature&.to_sym || @transaction_prompts.get_nature
        @rts.create_recurring(category: category, merchant: merchant, price: price, init_date: init_date, nature: nature, period_type: period_type)
        PROMPT.ok("Created recurring transaction successfully! Category: #{category.title} | Merchant: #{merchant} | #{nature.to_s.capitalize}: #{price} | Period: #{period_type}")
      end
    end

    class EditRecurring
      # @param bs [BudgetService]
      # @param rs [ReportService]
      # @param rts [RecurringTransactionService]
      def initialize(bs, rs, rts)
        @bs = bs
        @rs = rs
        @rts = rts
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @category_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @recurring_prompts = Prompts::RecurringTransactionPrompts.new(PROMPT, PASTEL)
        @helper = Commands::Helpers.new(bs: @bs, rs: @rs, category_prompts: @category_prompts, transaction_prompts: @transaction_prompts)
      end

      def run
        choice = RecurringTransactions.choose_recurring(@rts, @recurring_prompts)
        changes = @recurring_prompts.get_changes(choice)
        category = @helper.get_category if changes.include? "Category"
        merchant = @helper.choose_merchant if changes.include? "Merchant"
        init_date = PeriodDefiner.define_day(@recurring_prompts.get_init_date) if changes.include? "Initial date"
        nature = @transaction_prompts.get_nature if changes.include? "Nature"
        period_type = @recurring_prompts.get_period_type if changes.include? "Period"
        price = @recurring_prompts.get_price(period_type) if changes.include? "Amount"
        
        puts PASTEL.bold @helper.previous_and_new(choice.category.title, category.title) if category
        puts PASTEL.bold @helper.previous_and_new(choice.merchant, merchant) if merchant
        puts PASTEL.bold @helper.previous_and_new(choice.init_date, init_date) if init_date
        puts PASTEL.bold @helper.previous_and_new(choice.nature, nature) if nature
        puts PASTEL.bold @helper.previous_and_new(choice.price, price) if price
        puts PASTEL.bold @helper.previous_and_new(choice.period_type, period_type) if period_type
        @rts.edit_recurring(choice, category:, merchant:, init_date:, nature:, price:, period_type:)
        PROMPT.ok("Transaction edited successfully!")
      end
    end

    class DeleteRecurring
      # @param rts [RecurringTransactionService]
      def initialize(rts)
        @rts = rts
        @recurring_prompts = Prompts::RecurringTransactionPrompts.new(PROMPT, PASTEL)
        @general = Prompts::General.new(PROMPT)
      end

      def run
        choice = RecurringTransactions.choose_recurring(@rts, @recurring_prompts)
        return unless choice
        if @general.confirmed
          @rts.delete_recurring(choice)
          PROMPT.ok("Deleted successfully!")
          return 
        else 
          puts PASTEL.bright_red.bold "Cancelled"
          return
        end
      end

    end

    class ViewRecurring
      # @param rts [RecurringTransactionService]
      def initialize(rts)
        @rts = rts
      end

      def run(options: nil)
        recurring = @rts.find_by_attrs(**options)
        puts ""
        recurring.each do |r|
          RecurringTransactions.format_recurring(r)
          puts "-" * 57
        end
      end
    end

    class SyncRecurring
      # @param rts [RecurringTransactionService]
      def initialize(rts)
        @rts = rts
        @recurring_prompts = Prompts::RecurringTransactionPrompts.new(PROMPT, PASTEL)
      end

      def run
        recurring = @rts.find_by_attrs(unprocessed: true)
        if recurring.size == 0
          puts "You have no missed recurring transactions!"
          return
        end
        puts "You have #{recurring.size} recurring transactions to sync!"
        choices = recurring.map do |rec|
          {
            name: "#{rec.init_date.to_s.ljust(10)} | #{rec.merchant&.ljust(20)} | Amount due: #{rec.price}, on: #{rec.next_due}",
            value: rec
          }
        end
        ignored = RecurringTransactions.choose_recurring_to_ignore(choices)
        res = recurring - ignored
        pp res
        @rts.process_due(res)
      end
    end

    # @param rts [RecurringTransactionRepository]
    # @param recurring_prompts [Prompts::RecurringTransactionPrompts]
    def self.choose_recurring(rts, recurring_prompts)
      choices = rts.all&.map do |rec|
        {
          name: PASTEL.bold("#{PASTEL.public_send(rec.category&.colour, rec.category.title)} | #{rec.merchant} | #{rec.nature} | #{rec.price} | #{rec.period_type}"),
          value: rec
        }
      end

      if choices.empty?
        return nil
      end

      return recurring_prompts.get_recurring_choice(choices)
    end

    def self.choose_recurring_to_ignore(choices)
      PROMPT.multi_select("Choose transactions to ignore:", choices)
    end

    # @param recurring [RecurringTransaction]
    def self.format_recurring(recurring)
      category = PASTEL.public_send(recurring.category.colour)
      amount = case recurring.nature
      when :expense then PASTEL.bold.bright_red(recurring.price)
      when :investment then PASTEL.bold.bright_yellow(recurring.price)
      when :income then PASTEL.bold.bright_green(recurring.price)
      end

      check_string = recurring.next_due > Date.today ? PASTEL.bold.bright_green("✓ - Done for this #{recurring.get_period_string}")
        : PASTEL.bold.bright_red("𐄂 - Not completed for this #{recurring.get_period_string} - run #{PASTEL.bold.bright_blue "budget recurring sync"}")

      puts ["#{category.bold(recurring.category.title.ljust(15))}",
      "#{PASTEL.bold recurring.merchant.ljust(15)}",
      "#{amount} per #{recurring.get_period_string} #{recurring.nature}".ljust(35),
      "#{PASTEL.cyan(recurring.next_due)}",
      "#{check_string}"
    ].join(" · ")
  
      
    end
  end
end