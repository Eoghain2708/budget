require_relative 'commands'

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
        init_date = DateHelper.parse_arg(init_date)

        period_type = period_type&.to_s || @recurring_prompts.get_period_type
        price ||= @recurring.get_price(period_type)
        nature = nature&.to_sym || @transaction_prompts.get_nature

        @rts.create_recurring(category:, merchant:, price:, init_date:, nature:, period_type:)
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
        init_date = @recurring_prompts.get_init_date if changes.include? "Initial date"
        nature = @transaction_prompts.get_nature if changes.include? "Nature"
        price = @recurring_prompts.get_price if changes.include? "Amount"
        period_type = @recurring_prompts.get_period_type if changes.include? "Period"
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
        @general = Prompts::General.new(PROMPT, PASTEL)
      end

      def run
        choice = RecurringTransactions.choose_recurring(@rts, @recurring_prompts)
        if @general.confirmed
          @rts.delete_recurring(choice.id)
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

      def run(options)
        recurring = @rts.find_by_attrs(**options)
        recurring.each { |r| format_recurring(r) }
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
            name: "#{rec.init_date.to_s.ljust(10)} | #{rec.category.title.ljust(20)} | #{rec.merchant.ljust(20)} | #{rec.amount.to_s.rjust(7)} | (#{rec.nature})",
            value: rec
          }
        end
        res = recurring - choices
        @rts.process_due(res)
      end
    end

    # @param rts [RecurringTransactionRepository]
    # @param recurring_prompts [Prompts::RecurringTransactionPrompts]
    def self.choose_recurring(rts, recurring_prompts)
      choices = @rts.all.map do |rec|
        {
          name: PASTEL.bold("#{PASTEL.public_send(rec.category.colour, rec.category.title)} | #{rec.merchant} | #{rec.nature} | #{rec.price} | #{rec.period_type}"),
          value: rec
        }
      end

      return recurring_prompts.get_recurring_choice(choices)
    end

    # @param recurring [RecurringTransaction]
    def format_recurring(recurring)
      puts "Category: #{PASTEL.public_send(recurring.category.colour, recurring.category.title)}"
      puts "Merchant: #{recurring.merchant}"
      puts "Amount: #{recurring.amount} per #{recurring.get_period_string}"
      puts "Nature: #{recurring.nature}"
      puts "Next payment: #{recurring.next_due}"
    end
  end
end