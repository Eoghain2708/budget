require 'tty-prompt'
require 'pastel'
require_relative '../models/category'

module Prompts
  PROMPT = TTY::Prompt.new
  class General
    def initialize(prompt)
      @prompt = prompt
    end

    def confirmed
      @prompt.yes?('Are you sure?')
    end
  end

  class CategoryPrompts
    # @param prompt [TTY::Prompt]
    # @param pastel [Pastel]
    def initialize(prompt, pastel)
      @prompt = prompt
      @pastel = pastel
    end

    def get_title
      @prompt.ask('Enter a name for your category')
    end

    def get_colour
      @prompt.select('Select a colour', Category::ALLOWED_COLOURS)
    end

    def get_wants_to_change_title
      @prompt.yes?('Do you want to change title?')
    end

    def get_wants_to_change_colour
      @prompt.yes?('Do you want to change colour?')
    end
  end

  class TransactionPrompts
    # @param prompt [TTY::Prompt]
    # @param pastel [Pastel]
    def initialize(prompt, pastel)
      @prompt = prompt
      @pastel = pastel
    end

    # @return [Symbol]
    def get_nature
      @prompt.select('Is this an outgoing or incoming amount, or an investment?', %w[expense income investment]).to_sym
    end

    # @param categories [Array<String>]
    # @return [Category]
    def get_category(categories)
      @prompt.select('Choose a category', categories, per_page: 15)
    end

    # @return [String]
    def select_merchant(options)
      @prompt.select('Choose a merchant', options, per_page: 15)
    end

    def get_merchant
      @prompt.ask("Enter the merchant's name")
    end

    # @return [String]
    def get_price
      @prompt.ask('Enter the value of the transaction in pounds (##.##)')
    end

    # @return [String]
    def get_date
      @prompt.ask('Enter the date (YY-mm-DD, or use a shorthand date)')
    end

    # @param choices [Array<String>]
    # @return [Transaction]
    def get_transaction(choices)
      @prompt.select('Choose a transaction', choices)
    end

    def get_changes
      choices = %w[date category merchant price nature]
      @prompt.multi_select("Select the attributes you'd like to change:", choices, cycle: true)
    end

    # @param transactions [Array<Transaction>]
    # @return [Array<Transaction>]
    def find_transactions_to_ignore(transactions)
      @prompt.multi_select("Select the transactions you wish to ignore", transactions, cycle: true)
    end
  end

  class LimitPrompts
    def initialize(prompt, pastel)
      @prompt = prompt
      @pastel = pastel
    end

    # @return [Symbol]
    def get_category_or_merchant
      @prompt.select('Is this limit for a specific merchant or a Category?', %w[merchant category]).to_sym
    end

    # @return [Symbol]
    def get_period_type
      @prompt.select('What is period for this limit?', %w[daily weekly monthly yearly]).to_sym
    end

    # @return [Float]
    def get_amount
      @prompt.ask('Enter a float value for the limit amount')
    end

    # @param limits [Array<Limit>]
    # @return [Limit]
    def get_limit(limits)
      @prompt.select('Select a limit', limits)
    end

    # @param limit [Limit] - needed to check if limit is merchant or category
    def get_changes(limit)
      choices = ['period-type', 'amount']
      choices << if limit.merchant?
                   'merchant'
                 else
                   'category'
                 end
      @prompt.multi_select("Select the attributes you'd like to change:", choices, cycle: true)
    end
  end

  class RecurringTransactionPrompts
    def initialize(prompt, pastel)
      @prompt = prompt
      @pastel = pastel
    end

    def get_init_date
      @prompt.ask("Enter the initial date (first payment) in format YY-mm-dd or using shorthand")
    end

    # @return [Symbol]
    def get_period_type
      @prompt.select('What is period for this limit?', %w[daily weekly monthly yearly]).to_sym
    end

    # @return [Float]
    def get_price(period)
      @prompt.ask("Enter the #{period} amount").to_f
    end

    def get_recurring_choice(choices)
      @prompt.select("Choose a recurring transaction", choices)
    end

    # @param choice [RecurringTransaction]
    def get_changes(choice)
      choices = ['Category', 'Merchant', 'Initial date', 'Amount', 'Period', 'Nature']
      @prompt.multi_select("Select the attributes you'd like to change", choices, cycle: true)
    end

    # @param recurring [Array<RecurringTransaction>]
    def get_ignored(recurring)
      @prompt.multi_select("Select any that you would like to ignore.", recurring, cycle: true)
    end
  end

  class TradingPrompts
    def self.get_wants_to_configure?
      PROMPT.ask("Configure?")
    end
  end
end
