require "tty-prompt"
require "pastel"
require_relative "../models/category"

module Prompts

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
      @prompt.select("Is this an outgoing or incoming amount?", %w(expense income)).to_sym
    end

    # @param categories [Array<String>]
    # @return [Category]
    def get_category(categories)
      @prompt.select("Choose a category", categories)
    end

    # @return [String]
    def select_merchant(options)
      @prompt.select("Choose a merchant", options)
    end

    def get_merchant
      @prompt.ask("Enter the merchant's name")
    end

    # @return [String]
    def get_price
      @prompt.ask("Enter the value of the transaction in pounds (##.##)")
    end

  end
  
end