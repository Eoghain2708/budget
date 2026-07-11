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
    
    # @return [String]
    def get_nature
      @prompt.select("Is this an outgoing or incoming amount?", %w(expense income))
    end

    # @param categories [Array<String>]
    # @return [String]
    def get_category(categories)
      @prompt.select("Choose a category", categories)
    end

    # @return [String]
    def get_merchant
      @prompt.ask("Enter the merchant's name")
    end

    # @return [String]
    def get_price
      @prompt.ask("Enter the value of the transaction in pounds (##.##)")
    end

  end
  
end