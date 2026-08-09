require_relative 'commands'

module Commands
  module Transactions
    PROMPT = TTY::Prompt.new
    PASTEL = Pastel.new
    class AddTransaction
      # @param bs [BudgetService]
      # @param rs [ReportService]
      def initialize(bs, rs)
        @bs = bs
        @rs = rs
        @transaction_prompts = Prompts::TransactionPrompts.new(PROMPT, PASTEL)
        @category_prompts = Prompts::CategoryPrompts.new(PROMPT, PASTEL)
        @helper = Helpers.new(bs: @bs, rs: @rs, transaction_prompts: @transaction_prompts,
                              category_prompts: @category_prompts)
        Dotenv.load
      end

      def run(nature: nil, date: nil, price: nil, category: nil, merchant: nil)
        category = @bs.find_category_by_title(category) if category
        category ||= @helper.get_category

        merchant = ENV['WORKPLACE'] if category.title.strip.downcase == 'work' && ENV['WORKPLACE']

        nature = nature.to_sym if nature ||= @transaction_prompts.get_nature

        merchant ||= @helper.choose_from_recent_merchants(category)

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
        @helper = Helpers.new(bs: @bs, rs: @rs, transaction_prompts: @transaction_prompts)
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
        @helper = Helpers.new(bs: @bs, rs: @rs, transaction_prompts: @transaction_prompts)
      end

      def run(from:, to: from)
        return unless from

        choice = @helper.get_transaction_choice_between_dates(from: from, to: to)
        return unless choice

        changes = @transaction_prompts.get_changes

        new_category = @helper.get_category if changes.include?('category')

        new_date = PeriodDefiner.define_day(@transaction_prompts.get_date) if changes.include?('date')

        new_merchant = @helper.choose_merchant if changes.include?('merchant')

        new_price = @transaction_prompts.get_price if changes.include?('price')

        new_nature = @transaction_prompts.get_nature.to_sym if changes.include?('nature')

        # print out changes
        if new_category
          puts PASTEL.bold.bright_yellow @helper.previous_and_new(choice.category.title, new_category.title,
                                                                  'Category')
        end

        puts PASTEL.bold.bright_blue @helper.previous_and_new(choice.date.to_s, new_date, 'Date') if new_date
        puts PASTEL.bold.cyan @helper.previous_and_new(choice.merchant, new_merchant, 'Merchant') if new_merchant
        puts PASTEL.bold @helper.previous_and_new(choice.price, new_price, 'Price') if new_price
        puts PASTEL.bold @helper.previous_and_new(choice.nature, new_nature, 'Nature') if new_nature
        @bs.edit_transaction(choice.id, new_price: new_price, new_category: new_category, new_date: new_date,
                                        new_merchant: new_merchant, new_nature: new_nature)
        puts PASTEL.bold.bright_green('Edited successfully!')
      end
    end
  end
end
