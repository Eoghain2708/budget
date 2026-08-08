require "tty-prompt"
require "pastel"
require_relative "../models/category"

module Prompts

  class General
    def initialize(prompt)
      @prompt = prompt
    end

    def confirmed
      @prompt.ask("Are you sure?")
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
      @prompt.ask("Enter a name for your category")
    end

    def get_colour
      @prompt.select("Select a colour", Category::ALLOWED_COLOURS)
    end

    def get_wants_to_change_title
      @prompt.yes?("Do you want to change title?")
    end

    def get_wants_to_change_colour
      @prompt.yes?("Do you want to change colour?")
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
      @prompt.select("Is this an outgoing or incoming amount, or an investment?", %w(expense income investment)).to_sym
    end

    # @param categories [Array<String>]
    # @return [Category]
    def get_category(categories)
      @prompt.select("Choose a category", categories, per_page: 15)
    end

    # @return [String]
    def select_merchant(options)
      @prompt.select("Choose a merchant", options, per_page: 15)
    end

    def get_merchant
      @prompt.ask("Enter the merchant's name")
    end

    # @return [String]
    def get_price
      @prompt.ask("Enter the value of the transaction in pounds (##.##)")
    end

    # @return [String]
    def get_date
      @prompt.ask("Enter the new date (YY-mm-DD, or use a shorthand date)")
    end


    # @param choices [Array<String>]
    # @return [Transaction]
    def get_transaction(choices)
      @prompt.select("Choose a transaction", choices)
    end

    def get_changes
      choices = ["date", "category", "merchant", "price", "nature"]
      @prompt.multi_select("Select the attributes you'd like to change:", choices, cycle: true)
    end
  end

  class LimitPrompts
    def initialize(prompt, pastel)
      @prompt = prompt
      @pastel = pastel
    end

    # @return [Symbol]
    def get_category_or_merchant
      @prompt.select("Is this limit for a specific merchant or a Category?", %w(merchant category)).to_sym
    end

    # @return [Symbol]
    def get_period_type
      @prompt.select("What is period for this limit?", %w(daily weekly monthly yearly)).to_sym
    end

    # @return [Float]
    def get_amount
      @prompt.ask("Enter a float value for the limit amount")
    end

    # @param limits [Array<Limit>]
    # @return [Limit]
    def get_limit(limits)
      @prompt.select("Select a limit to delete", limits)
    end

    # @param limit [Limit] - needed to check if limit is merchant or category
    def get_changes(limit)
      choices = ["period-type, amount"]
      if limit.merchant?
        choices << "merchant"
      else 
        choices << "category"
      end
      @prompt.multi_select("Select the attributes you'd like to change:", choices, cycle: true)
    end
  end
  
end